using UnityEngine;

public class UTGBattleSkillBehaviourR600000212 : NTGBattleSkillSingleHit
{
    public void OnTriggerEnter(Collider other)
    {
        if (owner == null)
            return;

        var otherUnit = other.GetComponent<NTGBattleUnitController>();
        if (otherUnit != null && otherUnit.alive && otherUnit.group != owner.group && (mask & otherUnit.mask) != 0)
        {
            var dir = other.transform.position - shooter.transform.position;
            dir = new Vector3(dir.x, 0, dir.z);
            if (dir.sqrMagnitude > 0.01f)
            {
                var angle = Vector3.Angle(new Vector3(shooter.transform.forward.x, 0, shooter.transform.forward.z), dir);
                if (angle > targetAngle/2)
                    return;
            }

            otherUnit.Hit(owner, this);

            if (!(otherUnit is NTGBattleMobController && (otherUnit as NTGBattleMobController).type == 3))
                otherUnit.AddPassive("Blow", shooter, p: new[] {this.param[1]});

            FXHit(otherUnit);
        }
    }
}