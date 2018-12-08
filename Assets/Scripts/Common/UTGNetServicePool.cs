using System.Collections.Generic;
using System.Runtime.Remoting.Messaging;
using Newtonsoft.Json.Utilities;
using UnityEngine;
using System.Collections;

public class UTGNetServicePool
{
    public Dictionary<string, ArrayList> netRequestPool;

    public UTGNetServicePool()
    {
        netRequestPool = new Dictionary<string, ArrayList>();
    }

    public TGNetService.NetRequest NewRequest(string type)
    {
        if (netRequestPool.ContainsKey(type) && netRequestPool[type].Count > 0)
        {
            var request = (TGNetService.NetRequest) netRequestPool[type][0];
            netRequestPool[type].RemoveAt(0);
            return request;
        }

        return null;
    }

    public void ReleaseRequest(TGNetService.NetRequest request)
    {
        var type = request.Content["Type"].ToString();
        if (!netRequestPool.ContainsKey(type))
        {
            netRequestPool.Add(type, new ArrayList());
        }

        if (netRequestPool[type].Count < 100)
            netRequestPool[type].Add(request);
    }
}