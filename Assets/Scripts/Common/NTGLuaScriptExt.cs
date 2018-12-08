using System;
using LuaInterface;
using UnityEngine;
using System.Collections;

public class NTGLuaScriptExt : NTGLuaScript
{
    public bool eventUpdate;
    public bool eventFixedUpdate;
    public bool eventLateUpdate;

    public bool eventOnTriggerStay;

    private LuaFunction UpdateFunction;
    private LuaFunction FixedUpdateFunction;
    private LuaFunction LateUpdateFunction;
    private LuaFunction OnTriggerStayFunction;

    protected void Awake()
    {
        base.Awake();

        //if (eventUpdate && self != null)
        //{
        //    UpdateFunction = NTGApplicationController.Instance.LuaGetFunction(module, "Update");
        //}

        //if (eventFixedUpdate && self != null)
        //{
        //    FixedUpdateFunction = NTGApplicationController.Instance.LuaGetFunction(module, "FixedUpdate");
        //}

        if (eventLateUpdate && self != null)
        {
            LateUpdateFunction = NTGApplicationController.Instance.LuaGetFunction(module, "LateUpdate");
        }

        //if (eventOnTriggerStay && self != null)
        //{
        //    OnTriggerStayFunction = NTGApplicationController.Instance.LuaGetFunction(module, "OnTriggerStay");
        //}
    }

    //private void Update()
    //{
    //    if (eventUpdate && self != null)
    //    {
    //        UpdateFunction.Call(self);
    //    }
    //}

    //public void FixedUpdate()
    //{
    //    if (eventFixedUpdate && self != null)
    //    {
    //        FixedUpdateFunction.Call(self);
    //    }
    //}

    public void LateUpdate()
    {
        if (eventLateUpdate && self != null)
        {
            LateUpdateFunction.BeginPCall();
            LateUpdateFunction.Push(self);
            LateUpdateFunction.PCall();
            LateUpdateFunction.EndPCall();
        }
    }

    //public void OnTriggerStay(Collider other)
    //{
    //    if (eventOnTriggerStay && self != null)
    //    {
    //        OnTriggerStayFunction.Call(self, other);
    //    }
    //}
}