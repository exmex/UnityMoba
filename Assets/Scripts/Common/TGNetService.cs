using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using ICSharpCode.SharpZipLib.GZip;
using ICSharpCode.SharpZipLib.Zip.Compression;
using Newtonsoft.Json.Linq;
using UnityEngine;


public class TGNetService
{
    public static int DebugLevel = 2; //0:Release 1:Debug 2:Verbose

    public const int ReceiveTimeout = 90000;
    public const int PingRate = 1000;

    public string serverIp;
    public int serverPort;

    public UTGNetServicePool pool;

    private class RawSerializer<T>
    {
        public T RawDeserialize(byte[] rawData)
        {
            int rawsize = Marshal.SizeOf(typeof (T));
            if (rawsize > rawData.Length)
                return default(T);

            IntPtr buffer = Marshal.AllocHGlobal(rawsize);
            Marshal.Copy(rawData, 0, buffer, rawsize);
            var obj = (T) Marshal.PtrToStructure(buffer, typeof (T));
            Marshal.FreeHGlobal(buffer);
            return obj;
        }

        public byte[] RawSerialize(T item)
        {
            int rawSize = Marshal.SizeOf(typeof (T));
            IntPtr buffer = Marshal.AllocHGlobal(rawSize);
            Marshal.StructureToPtr(item, buffer, false);
            var rawData = new byte[rawSize];
            Marshal.Copy(buffer, rawData, 0, rawSize);
            Marshal.FreeHGlobal(buffer);
            return rawData;
        }
    }

    private class SyncQueue<T>
    {
        private readonly Queue queue;

        public SyncQueue()
        {
            queue = Queue.Synchronized(new Queue());
        }

        public void EnQueue(T obj)
        {
            lock (queue)
            {
                queue.Enqueue(obj);
                Monitor.Pulse(queue);
            }
        }

        public T Peek()
        {
            T item = default(T);
            lock (queue)
            {
                while (queue.Count == 0) Monitor.Wait(queue);
                item = (T) queue.Peek();
            }
            return item;
        }

        public T DeQueue()
        {
            T item = default(T);
            lock (queue)
            {
                while (queue.Count == 0) Monitor.Wait(queue);
                item = (T) queue.Dequeue();
            }
            return item;
        }

        public T TryDeQueue()
        {
            T item = default(T);
            lock (queue)
            {
                if (queue.Count > 0)
                    item = (T) queue.Dequeue();
            }
            return item;
        }
    }

    private Deflater deflater = new Deflater(Deflater.BEST_SPEED, true);
    private Inflater inflater = new Inflater(true);

    private byte[] deflaterBuffer = new byte[4096];
    private byte[] inflaterBuffer = new byte[4096];

    private byte[] decompressBuffer = new byte[40960];

    private byte[] GZip(byte[] input, int size, out int length)
    {
        if (size == 0)
        {
            var memory = new MemoryStream();            
            deflater.Reset();
            using (var stream = new GZipOutputStream(memory, deflater, 4096, deflaterBuffer))
            {                   
                stream.Write(input, 0, input.Length);
            }

            var array = memory.ToArray();
            length = array.Length;
            return array;
        }
        else
        {
            if (size > decompressBuffer.Length)
            {
                decompressBuffer = new byte[size];
            }

            inflater.Reset();
            using (var stream = new GZipInputStream(new MemoryStream(input), inflater, 4096, inflaterBuffer))
            {
                stream.Read(decompressBuffer, 0, size);
            }

            length = size;
            return decompressBuffer;
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct Header
    {
        public uint Sign;
        public uint Channel;
        public uint Bodysize;
        public uint ContentSize;
        public uint DataSize;
    }

    private readonly RawSerializer<Header> headerRawSerializer = new RawSerializer<Header>();

    public class NetEvent
    {
        public string Type;
        public JObject Content;
        public byte[] Data;
        public object Param;
    }

    public class NetRequest
    {
        public string Type;
        public JObject Content;
        public byte[] Data = null;
        public object Param = null;

        public NetEventHanlder Handler = null;
        public bool FlowOpt = false;
    }

    private enum NetServiceChannel
    {
        Primary,
        Secondary,
        Count
    }

    private class Server
    {
        public Socket soc;
        public SyncQueue<NetEvent>[] eventQueue;
        public SyncQueue<NetRequest> requestQueue;
        public SyncQueue<NetRequest> responseQueue;
        public TimeSpan latency = new TimeSpan(long.MaxValue);
        public TimeSpan timeOffset = new TimeSpan(0);
        public TimeSpan timeOffsetLatency = new TimeSpan(long.MaxValue);
    }

    private const uint SIGN = 0xFEFEEFEF;

    private static TGNetService instance;
    private Thread serviceThread;
    private bool running = false;

    public bool IsRunning()
    {
        return running;
    }

    private Server server = null;

    public static TGNetService GetInstance()
    {
        if (instance == null)
        {
            instance = new TGNetService();
        }

        return instance;
    }

    public static TGNetService NewInstance()
    {
        instance.Stop();
        instance = new TGNetService();
        return instance;
    }

    private TGNetService()
    {
        eventHandles = new Dictionary<string, ArrayList>();
        eventHandlesRemove = new ArrayList();

        pool = new UTGNetServicePool();
    }

    public void Start(string serverIp, int serverPort)
    {
        this.serverIp = serverIp;
        this.serverPort = serverPort;
        running = true;
        serviceThread = new Thread(serviceThreadRoutine);
        serviceThread.Start();
    }

    public void Stop()
    {
        Debug.LogError("Stop called!");
        if (running)
        {
            running = false;
            serviceThread.Interrupt();
        }
    }

#if NET_DEBUG
    public System.Diagnostics.Stopwatch sendStopwatch = new Stopwatch();
    public System.Diagnostics.Stopwatch recvStopwatch = new Stopwatch();

    public System.Diagnostics.Stopwatch sendThreadStopwatch = new Stopwatch();
    public System.Diagnostics.Stopwatch recvThreadStopwatch = new Stopwatch();
    public System.Diagnostics.Stopwatch beatThreadStopwatch = new Stopwatch();
#endif

    private void sendBody(Socket soc, NetServiceChannel channel, string str, byte[] data)
    {
#if NET_DEBUG
        sendStopwatch.Start();
#endif
        //lock (soc)
        {
            byte[] content = Encoding.UTF8.GetBytes(str);
            int length;
            byte[] body = GZip(content, 0, out length);

            if (DebugLevel > 1)
            {
                if(JObject.Parse(str)["Type"].ToString() != "Beat")
                Debug.Log(String.Format("<<< ch:{3} sending {0}->{1} body:{2}", content.Length, length, str, channel));
            }

            Header header = new Header
            {
                Sign = SIGN,
                Channel = (uint) channel,
                Bodysize = (uint) length,
                ContentSize = (uint) content.Length,
            };
            header.DataSize = (data == null) ? 0 : (uint) data.Length;

            byte[] head = headerRawSerializer.RawSerialize(header);
            soc.SendTimeout = 10000;
            if (soc.Send(head) != Marshal.SizeOf(typeof (Header)))
            {
                throw new Exception("send header failed");
            }

            soc.SendTimeout = 30000;
            if (soc.Send(body, length, SocketFlags.None) != length)
            {
                throw new Exception("send body failed");
            }

            if (data != null)
            {
                if (soc.Send(data) != data.Length)
                {
                    throw new Exception("send data failed");
                }
            }
        }
#if NET_DEBUG
        sendCount++;
        sendStopwatch.Stop();
#endif
    }

    private string recvBody(Socket soc, ref NetServiceChannel channel, ref byte[] data)
    {
#if NET_DEBUG
        recvStopwatch.Start();
#endif
        var headSize = Marshal.SizeOf(typeof (Header));
        var head = new byte[headSize];
        var headRead = 0;

        while (headRead < headSize)
        {
            soc.ReceiveTimeout = ReceiveTimeout;
            var n = soc.Receive(head, headRead, headSize - headRead, SocketFlags.None);
            headRead += n;
        }

        if (headRead != headSize)
        {
            throw new Exception("recv header failed " + headRead.ToString());
        }

        Header header = headerRawSerializer.RawDeserialize(head);
        if (header.Sign != SIGN)
        {
            throw new Exception("recv header sign mismatch");
        }

        channel = (NetServiceChannel) header.Channel;

        var bytesExpected = (int) header.Bodysize;
        var body = new byte[bytesExpected];
        var bytesRead = 0;

        while (bytesRead < bytesExpected)
        {
            soc.ReceiveTimeout = 10000;
            var n = soc.Receive(body, bytesRead, bytesExpected - bytesRead, SocketFlags.None);
            bytesRead += n;
        }

        int length;
        byte[] content = GZip(body, (int) header.ContentSize, out length);

        if (length != header.ContentSize)
        {
            throw new Exception("received body content size mismatch");
        }

        string str = Encoding.UTF8.GetString(content, 0, length);
        if (DebugLevel > 1)
        {
            if(JObject.Parse(str)["Type"].ToString() != "Beat")
                Debug.Log(String.Format(">>> ch:{3} receiving {0}->{1} body:{2}", header.ContentSize, header.Bodysize, str, channel));
        }

        data = null;
        if (header.DataSize > 0)
        {
            var dataExpected = (int) header.DataSize;
            data = new byte[dataExpected];
            var dataRead = 0;

            while (dataRead < dataExpected)
            {
                soc.ReceiveTimeout = 30000;
                var n = soc.Receive(data, dataRead, dataExpected - dataRead, SocketFlags.None);
                dataRead += n;
            }
        }
#if NET_DEBUG
        recvCount++;
        recvStopwatch.Stop();
#endif

        return str;
    }

    private ManualResetEvent connectDone = new ManualResetEvent(false);
    private bool connected = false;

    private void ConnectCallback(IAsyncResult ar)
    {
        Socket s = (Socket) ar.AsyncState;
        s.EndConnect(ar);
        connected = true;
        connectDone.Set();
    }

    private void serviceThreadRoutine()
    {
        Server previousServer = null;

        while (running)
        {
            //Debug.Log("New Server Enter");
            lock (eventHandles)
            {
                previousServer = server;
                server = new Server();
                if (previousServer != null)
                {
                    server.requestQueue = previousServer.requestQueue;
                    server.responseQueue = previousServer.responseQueue;
                    server.eventQueue = previousServer.eventQueue;
                }
                else
                {
                    server.requestQueue = new SyncQueue<NetRequest>();
                    server.responseQueue = new SyncQueue<NetRequest>();
                    server.eventQueue = new SyncQueue<NetEvent>[(int) NetServiceChannel.Count];
                    for (var i = 0; i < server.eventQueue.Length; i++)
                    {
                        server.eventQueue[i] = new SyncQueue<NetEvent>();
                    }
                }
            }
            //Debug.Log("New Server Exit");

            Thread recvThread = null;
            Thread beatThread = null;
            connected = false;
            connectDone.Reset();

            try
            {
                server.soc = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                //server.soc.NoDelay = true;

                Debug.Log("Connecting to Server " + serverIp);

                server.soc.BeginConnect(serverIp, serverPort, ConnectCallback, server.soc);

                connectDone.WaitOne(1000, true);
                if (!connected)
                {
                    Debug.Log("Connect to Server Timeout");
                    throw new Exception("Connect to Server Timeout");
                }

                Debug.Log("Connected to Server " + server.soc.RemoteEndPoint);

                recvThread = new Thread(recvThreadRoutine);
                recvThread.Start(server);

                beatThread = new Thread(beatThreadRoutine);
                beatThread.Start();

                server.eventQueue[(int) NetServiceChannel.Secondary].EnQueue(new NetEvent
                {
                    Type = "Connect"
                });

                while (true)
                {
#if NET_DEBUG
                    sendThreadStopwatch.Start();
#endif

                    NetRequest request = server.requestQueue.Peek();
                    //Debug.Log("Receive Request " + request.Type);
                    if (request.Type == "Exception")
                    {
                        throw new Exception(request.Content["Content"].ToString());
                    }

                    sendBody(server.soc, NetServiceChannel.Primary, request.Content.ToString(), request.Data);

                    server.requestQueue.DeQueue();

                    if (!request.FlowOpt)
                    {
                        var e = server.eventQueue[(int) NetServiceChannel.Primary].DeQueue();
                        if (request.Handler != null)
                        {
                            server.responseQueue.EnQueue(new NetRequest
                            {
                                Type = e.Type,
                                Content = e.Content,
                                Data = e.Data,
                                Param = request.Param,
                                Handler = request.Handler
                            });
                        }
                    }

                    pool.ReleaseRequest(request);
#if NET_DEBUG
                    sendThreadStopwatch.Stop();
#endif
                }
            }
            catch (Exception e)
            {
                Debug.Log(e.ToString());
            }
            finally
            {
                if (connected)
                {
                    server.eventQueue[(int) NetServiceChannel.Secondary].EnQueue(new NetEvent
                    {
                        Type = "Disconnect"
                    });
                }

                if (beatThread != null)
                    beatThread.Interrupt();
                if (server.soc != null)
                    server.soc.Close();
            }

            Debug.Log("Disconnected Wait 1s to reconnect...");
            Thread.Sleep(1000);
        }

        Debug.Log("Net Thread Exit");
    }

    public static DateTime GetServerTime()
    {
        if (instance == null || instance.server == null)
        {
            return DateTime.Now;
        }
        return DateTime.Now + instance.server.timeOffset;
    }

    public static float GetServerPassedTime(DateTime startTime)
    {
        var t = GetServerTime() - startTime;

        return t.Minutes*60 + t.Seconds + t.Milliseconds/1000;
    }

    public static int GetServerLatency()
    {
        return instance.server.latency.Seconds*1000 + instance.server.latency.Milliseconds;
    }

    private void recvThreadRoutine(object obj)
    {
        var server = (Server) obj;
        try
        {
            while (true)
            {
#if NET_DEBUG
                recvThreadStopwatch.Start();
#endif

                var channel = NetServiceChannel.Primary;
                byte[] data = null;
                var response = JObject.Parse(recvBody(server.soc, ref channel, ref data));

                if (channel == NetServiceChannel.Secondary && response["Type"].ToString() == "Beat")
                {
                    Debug.Log("Beat Response Received");
                    if (response["TC"] != null)
                    {
                        var now = DateTime.Now;
                        var TC = DateTime.Parse(response["TC"].ToString());
                        var TS = DateTime.Parse(response["TS"].ToString());

                        server.latency = new TimeSpan((now - TC).Ticks/2);
                        if (DebugLevel > 0)
                        {
                            Debug.Log(String.Format("Server Latency:{0}ms", GetServerLatency()));
                        }
                        if (server.latency < server.timeOffsetLatency)
                        {
                            server.timeOffset = TS + server.latency - now;
                            server.timeOffsetLatency = server.latency;
                            //Debug.Log(String.Format("Server Time Sync\n{0}\n{1}\n{2}\n{3}", TC.ToString("o"), TS.ToString("o"), now.ToString("o"), server.timeOffset.ToString()));
                            Debug.Log(String.Format("TimeSync LocalTime {0} ServerTime {1} Offset {2} Latency {3}ms", now.ToString("o"), TS.Add(server.latency).ToString("o"), server.timeOffset, server.latency.Milliseconds));
                        }
                    }
#if NET_DEBUG
                    recvThreadStopwatch.Stop();
#endif
                    continue;
                }

                server.eventQueue[(int) channel].EnQueue(new NetEvent
                {
                    Type = response["Type"].ToString(),
                    Content = response,
                    Data = data
                });
#if NET_DEBUG
                recvThreadStopwatch.Stop();
#endif
            }
        }
        catch (Exception e)
        {
            Debug.Log(e.ToString());
            Debug.Log("Recv Thread Exit");
            //SendRequest(new NetRequest
            //{
            //    Content = new JObject(new JProperty("Type", "Exception"), new JProperty("Content", e.ToString()))
            //});
        }
    }

    private void beatThreadRoutine()
    {
        try
        {
            while (true)
            {
                SendRequest(new NetRequest
                {
                    Content = new JObject(new JProperty("Type", "Beat"), new JProperty("TC", DateTime.Now.ToString("o"))),
                    FlowOpt = true
                });
                //Debug.Log("Beat Sent");

                Thread.Sleep(PingRate);
            }
        }
        catch (Exception e)
        {
            //Debug.Log(e.ToString());
            Debug.Log("Beat Thread Exit");
            //SendRequest(new NetRequest
            //{
            //    Content = new JObject(new JProperty("Type", "Exception"), new JProperty("Content", e.ToString())),
            //    Data = null
            //});
        }
    }

    public delegate bool NetEventHanlder(NetEvent e);

    private class EventHandle
    {
        public NetEventHanlder handler;
        public int priority;
    }

    private Dictionary<string, ArrayList> eventHandles;

    private class EventHandleRemove
    {
        public string type;
        public NetEventHanlder handler;
    }

    private ArrayList eventHandlesRemove;

    public void AddEventHandler(string type, NetEventHanlder handler, int priority = 0)
    {
        ArrayList handles = null;
        if (!eventHandles.TryGetValue(type, out handles))
        {
            handles = new ArrayList();
            eventHandles.Add(type, handles);
        }

        EventHandle handle = new EventHandle {handler = handler, priority = priority};
        int index = 0;
        for (int i = 0; i < handles.Count; i++)
        {
            if (((EventHandle) handles[i]).priority <= handle.priority)
            {
                index = i;
                break;
            }
        }
        handles.Insert(index, handle);
    }

    public void RemoveEventHander(string type, NetEventHanlder handler)
    {
        EventHandleRemove remove = new EventHandleRemove {type = type, handler = handler};
        eventHandlesRemove.Add(remove);
    }

    public void SendRequest(NetRequest request)
    {
        if (server != null && server.requestQueue != null)
        {
            request.Type = request.Content["Type"].ToString();
            server.requestQueue.EnQueue(request);
        }
    }

#if NET_DEBUG
    public int sendCount;
    public int recvCount;
    public int profileCount;
#endif

    public IEnumerator NetEventDispatcher()
    {
        while (running)
        {
#if NET_DEBUG
            profileCount++;
            if (profileCount == 10)
            {
                if (sendCount != 0 || recvCount != 0)
                {
                    Debug.LogWarning(String.Format("SEND {0:D2} in {1:D5}ms RECV {2:D2} in {3:D5}ms ST in {4:D5}ms RT in {5:D5}ms",
                        sendCount, sendStopwatch.ElapsedMilliseconds, recvCount, recvStopwatch.ElapsedMilliseconds,
                        sendThreadStopwatch.ElapsedMilliseconds, recvThreadStopwatch.ElapsedMilliseconds));
                }

                sendCount = 0;
                recvCount = 0;
                sendStopwatch.Reset();
                recvStopwatch.Reset();
                sendThreadStopwatch.Reset();
                recvThreadStopwatch.Reset();

                profileCount = 0;
            }
#endif

            //Debug.Log("C");
            Monitor.Enter(eventHandles);
            if (server != null && server.eventQueue != null)
            {
                if (server.responseQueue != null)
                {
                    NetRequest r;
                    while ((r = server.responseQueue.TryDeQueue()) != null)
                    {
                        if (
                            !r.Handler(new NetEvent
                            {
                                Type = r.Type,
                                Content = r.Content,
                                Data = r.Data,
                                Param = r.Param
                            }))
                        {
                            Debug.LogError("Response Type not Match!");
                        }
                    }
                }

                for (var i = (int) NetServiceChannel.Secondary; i < (int) NetServiceChannel.Count; i++)
                {
                    if (server.eventQueue[i] != null)
                    {
                        NetEvent e;
                        while ((e = server.eventQueue[i].TryDeQueue()) != null)
                        {
                            ArrayList handles = null;
                            if (eventHandles.TryGetValue(e.Type, out handles))
                            {
                                foreach (EventHandle handle in handles)
                                {
                                    if (handle.handler(e))
                                    {
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }

                for (int i = eventHandlesRemove.Count - 1; i >= 0; i--)
                {
                    EventHandleRemove remove = (EventHandleRemove) eventHandlesRemove[i];

                    ArrayList handles = null;
                    if (eventHandles.TryGetValue(remove.type, out handles))
                    {
                        for (int j = handles.Count - 1; j >= 0; j--)
                        {
                            if (((EventHandle) handles[j]).handler == remove.handler)
                            {
                                handles.RemoveAt(j);
                            }
                        }
                    }

                    eventHandlesRemove.RemoveAt(i);
                }

                Monitor.Exit(eventHandles);
                yield return null;
                Monitor.Enter(eventHandles);
            }
            else
            {
                Monitor.Exit(eventHandles);
                yield return new WaitForSeconds(1);
                Monitor.Enter(eventHandles);
            }
            Monitor.Exit(eventHandles);
        }

        Debug.Log("Net Dispatcher Exit");
    }
}