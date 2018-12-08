using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class NTGEventTriggerProxy : UnityEngine.EventSystems.EventTrigger
{
    public delegate void BaseEventDelegate(BaseEventData eventData);

    public delegate void PointerEventDelegate(PointerEventData eventData);

    public delegate void AxisBaseEventDelegate(AxisEventData eventData);

    public PointerEventDelegate onBeginDrag;
    public BaseEventDelegate onCancel;
    public BaseEventDelegate onDeselect;
    public PointerEventDelegate onDrag;
    public PointerEventDelegate onDrop;
    public PointerEventDelegate onEndDrag;
    public PointerEventDelegate onInitializePotentialDrag;
    public AxisBaseEventDelegate onMove;
    public PointerEventDelegate onPointerClick;
    public PointerEventDelegate onPointerDown;
    public PointerEventDelegate onPointerEnter;
    public PointerEventDelegate onPointerExit;
    public PointerEventDelegate onPointerUp;
    public PointerEventDelegate onScroll;
    public BaseEventDelegate onSelect;
    public BaseEventDelegate onSubmit;
    public BaseEventDelegate onUpdateSelected;

    public static NTGEventTriggerProxy Get(GameObject go)
    {
        NTGEventTriggerProxy proxy = go.GetComponent<NTGEventTriggerProxy>();
        if (proxy == null) proxy = go.AddComponent<NTGEventTriggerProxy>();
        return proxy;
    }

    public override void OnBeginDrag(PointerEventData eventData)
    {
        if (onBeginDrag != null) onBeginDrag(eventData);
    }

    public override void OnCancel(BaseEventData eventData)
    {
        if (onCancel != null) onCancel(eventData);
    }

    public override void OnDeselect(BaseEventData eventData)
    {
        if (onDeselect != null) onDeselect(eventData);
    }

    public override void OnDrag(PointerEventData eventData)
    {
        if (onDrag != null) onDrag(eventData);
    }

    public override void OnDrop(PointerEventData eventData)
    {
        if (onDrop != null) onDrop(eventData);
    }

    public override void OnEndDrag(PointerEventData eventData)
    {
        if (onEndDrag != null) onEndDrag(eventData);
    }

    public override void OnInitializePotentialDrag(PointerEventData eventData)
    {
        if (onInitializePotentialDrag != null) onInitializePotentialDrag(eventData);
    }

    public override void OnMove(AxisEventData eventData)
    {
        if (onMove != null) onMove(eventData);
    }

    public override void OnPointerClick(PointerEventData eventData)
    {
        if (onPointerClick != null) onPointerClick(eventData);
    }

    public override void OnPointerDown(PointerEventData eventData)
    {
        if (onPointerDown != null) onPointerDown(eventData);
    }

    public override void OnPointerEnter(PointerEventData eventData)
    {
        if (onPointerEnter != null) onPointerEnter(eventData);
    }

    public override void OnPointerExit(PointerEventData eventData)
    {
        if (onPointerExit != null) onPointerExit(eventData);
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        if (onPointerUp != null) onPointerUp(eventData);
    }

    public override void OnScroll(PointerEventData eventData)
    {
        if (onScroll != null) onScroll(eventData);
    }

    public override void OnSelect(BaseEventData eventData)
    {
        if (onSelect != null) onSelect(eventData);
    }

    public override void OnSubmit(BaseEventData eventData)
    {
        if (onSubmit != null) onSubmit(eventData);
    }

    public override void OnUpdateSelected(BaseEventData eventData)
    {
        if (onUpdateSelected != null) onUpdateSelected(eventData);
    }
}