using UnityEngine;
using System.Collections;

public class UTGBattleSkillHintController : MonoBehaviour
{
    public NTGBattlePlayerController owner;
    public NTGBattleSkillController skill;

    public Transform circleHint;
    public Transform fan60Hint;
    public Transform fan90Hint;
    public Transform directionHint;

    public Transform rangeHint;
    public Transform targetHint;

    public Color cancelColor;
    public Color normalColor;


    public void Init(NTGBattlePlayerController owner)
    {
        this.owner = owner;

        targetHint.parent = owner.mainController.dynamics;
    }

    private void Start()
    {
        circleHint.gameObject.SetActive(false);
        fan60Hint.gameObject.SetActive(false);
        fan90Hint.gameObject.SetActive(false);
        directionHint.gameObject.SetActive(false);
        rangeHint.gameObject.SetActive(false);

        rangeHint.localPosition = new Vector3(0, 0.01f, 0);
        rangeHintRenderer = rangeHint.gameObject.GetComponent<Renderer>();
        rangeHintRenderer.material.SetColor("_Color", normalColor);

        targetHintRenderer = targetHint.gameObject.GetComponent<Renderer>();
        targetHintRenderer.material.SetColor("_Color", Color.red);

        StartCoroutine(doUpdateTargetHint());
    }

    private IEnumerator doUpdateTargetHint()
    {
        while (true)
        {
            if (owner != null && owner.alive && owner.targetUnit != null)
            {
                targetHint.gameObject.SetActive(true);
                targetHint.position = new Vector3(owner.targetUnit.transform.position.x, owner.targetUnit.transform.position.y + 0.01f, owner.targetUnit.transform.position.z);
                if (owner.targetUnit is NTGBattleMobTowerController)
                {
                    targetHint.localScale = new Vector3(2.5f, 1, 2.5f);
                }
                else
                {
                    targetHint.localScale = new Vector3(1, 1, 1);
                }
            }
            else
            {
                targetHint.gameObject.SetActive(false);
            }

            yield return null;
        }
    }

    public Transform hint;
    public int hintType;
    public float hintSize;
    public Vector3 hintOffset;
    public bool hintShow;

    public Renderer hintRenderer;
    public Renderer rangeHintRenderer;
    public Renderer targetHintRenderer;

    public void HintShow(NTGBattleSkillController skill)
    {
        this.skill = skill;
        hintType = skill.skill.HintType;
        hintSize = skill.skill.HintSize;

        hint = null;

        rangeHint.localScale = new Vector3(skill.range*2, 1, skill.range*2);

        if (hintType == 0)
        {
            hint = circleHint;
            hint.parent = owner.mainController.dynamics;
            hint.localScale = new Vector3(hintSize*2, 1, hintSize*2);
        }
        else if (hintType == 1 || hintType == 2)
        {
            if (hintType == 1)
            {
                hint = fan60Hint;
            }
            else if (hintType == 2)
            {
                hint = fan90Hint;
            }
            hint.parent = transform;
            hint.localScale = new Vector3(skill.range, 1, skill.range);
        }
        else if (hintType == 3)
        {
            hint = directionHint;
            hint.parent = transform;
            hint.localScale = new Vector3(hintSize*2, 1, skill.range);
        }

        if (hint == null)
            return;

        hintRenderer = hint.gameObject.GetComponent<Renderer>();
        hintRenderer.material.SetColor("_Color", normalColor);
        rangeHintRenderer.material.SetColor("_Color", normalColor);

        hintShow = true;
        rangeHint.gameObject.SetActive(true);
    }

    public void UpdateHint()
    {
        if (skill.type != NTGBattleSkillType.Attack && hintOffset.sqrMagnitude > 0.01f)
        {
            hint.gameObject.SetActive(true);

            if (hintType == 0)
            {
                hint.position = owner.transform.position + new Vector3(hintOffset.x, 0.01f, hintOffset.z);
            }
            else if (hintType == 1 || hintType == 2)
            {
                hint.localPosition = new Vector3(0, 0.01f, 0);
                hint.LookAt(new Vector3(hint.position.x + hintOffset.x, hint.position.y, hint.position.z + hintOffset.z));
            }
            else if (hintType == 3)
            {
                hint.localPosition = new Vector3(0, 0.01f, 0);
                hint.LookAt(new Vector3(hint.position.x + hintOffset.x, hint.position.y, hint.position.z + hintOffset.z));
            }
        }
        else
        {
            hint.gameObject.SetActive(false);
        }
    }

    public void HintCancel(bool cancel)
    {
        if (hintShow)
        {
            if (cancel)
            {
                hintRenderer.material.SetColor("_Color", cancelColor);
                rangeHintRenderer.material.SetColor("_Color", cancelColor);
            }
            else
            {
                hintRenderer.material.SetColor("_Color", normalColor);
                rangeHintRenderer.material.SetColor("_Color", normalColor);
            }
        }
    }

    public void HintHide()
    {
        hintShow = false;

        hint.gameObject.SetActive(false);
        rangeHint.gameObject.SetActive(false);
    }
}