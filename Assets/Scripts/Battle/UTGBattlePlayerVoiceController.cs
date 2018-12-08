using System;
using UnityEngine;
using System.Collections;
using Random = UnityEngine.Random;

public class UTGBattlePlayerVoiceController : MonoBehaviour
{
    public static float lastPlayTime;
    public static float minPlayGap;

    public NTGBattlePlayerController player;
    public bool isLocalPlayer;

    public AudioClip[] StartMovingClips;
    public AudioClip[] KeepMovingClips;
    public AudioClip[] Skill1ShootClips;
    public AudioClip[] Skill1HitPlayerClips;
    public AudioClip[] Skill1HitOtherClips;
    public AudioClip[] Skill2ShootClips;
    public AudioClip[] Skill2HitPlayerClips;
    public AudioClip[] Skill2HitOtherClips;
    public AudioClip[] Skill3ShootClips;
    public AudioClip[] Skill3HitPlayerClips;
    public AudioClip[] Skill3HitOtherClips;
    public AudioClip[] KillClips;

    private AudioClip[][] SkillShootClips;
    private AudioClip[][] SkillHitPlayerClips;
    private AudioClip[][] SkillHitOtherClips;


    public void Awake()
    {
        SkillShootClips = new AudioClip[3][];
        SkillShootClips[0] = Skill1ShootClips;
        SkillShootClips[1] = Skill2ShootClips;
        SkillShootClips[2] = Skill3ShootClips;

        SkillHitPlayerClips = new AudioClip[3][];
        SkillHitPlayerClips[0] = Skill1HitPlayerClips;
        SkillHitPlayerClips[1] = Skill2HitPlayerClips;
        SkillHitPlayerClips[2] = Skill3HitPlayerClips;

        SkillHitOtherClips = new AudioClip[3][];
        SkillHitOtherClips[0] = Skill1HitOtherClips;
        SkillHitOtherClips[1] = Skill2HitOtherClips;
        SkillHitOtherClips[2] = Skill3HitOtherClips;

        lastPlayTime = 0;
        minPlayGap = 0;
    }

    public void Init(NTGBattlePlayerController player)
    {
        this.player = player;

        isLocalPlayer = player == player.mainController.uiController.localPlayerController;
    }

    public void StartMoving()
    {
        if (isLocalPlayer && StartMovingClips.Length > 0 && !player.mainController.voiceSource.isPlaying && Time.time - lastPlayTime > minPlayGap)
        {
            var roll = Random.Range(0, StartMovingClips.Length - 1);
            player.mainController.voiceSource.PlayOneShot(StartMovingClips[roll]);

            lastPlayTime = Time.time;
            minPlayGap = Random.Range(15.0f, 30.0f);
        }
    }

    public void KeepMoving()
    {
        if (isLocalPlayer && KeepMovingClips.Length > 0 && !player.mainController.voiceSource.isPlaying && Time.time - lastPlayTime > minPlayGap)
        {
            var roll = Random.Range(0, KeepMovingClips.Length - 1);
            player.mainController.voiceSource.PlayOneShot(KeepMovingClips[roll]);

            lastPlayTime = Time.time;
            minPlayGap = Random.Range(15.0f, 30.0f);
        }
    }

    public void Kill(NTGBattleUnitController killer)
    {
        if ((isLocalPlayer || killer == player.mainController.uiController.localPlayerController) && KillClips.Length > 0 && !player.mainController.voiceSource.isPlaying && Time.time - lastPlayTime > minPlayGap)
        {
            var roll = Random.Range(0, KillClips.Length - 1);
            player.mainController.voiceSource.PlayOneShot(KillClips[roll]);

            lastPlayTime = Time.time;
            minPlayGap = Random.Range(15.0f, 30.0f);
        }
    }

    public void SkillShoot(int index)
    {
        if (isLocalPlayer && index > 0 && index < 4 && SkillShootClips[index - 1].Length > 0 && !player.mainController.voiceSource.isPlaying && Time.time - lastPlayTime > minPlayGap)
        {
            var roll = Random.Range(0, SkillShootClips[index - 1].Length - 1);
            player.mainController.voiceSource.PlayOneShot(SkillShootClips[index - 1][roll]);

            lastPlayTime = Time.time;
            minPlayGap = Random.Range(15.0f, 30.0f);
        }
    }

    public void SkillHit(int skillId, NTGBattleUnitController target)
    {
        if (player.mainController.voiceSource.isPlaying || !isLocalPlayer || Time.time - lastPlayTime < minPlayGap)
            return;

        var index = 0;
        for (int i = 1; i <= 3; i++)
        {
            if (player.skills[i].id == skillId)
            {
                index = i;
                break;
            }
        }

        if (index != 0)
        {
            if (target is NTGBattlePlayerController)
            {
                if (SkillHitPlayerClips[index - 1].Length > 0)
                {
                    var roll = Random.Range(0, SkillHitPlayerClips[index - 1].Length - 1);
                    player.mainController.voiceSource.PlayOneShot(SkillHitPlayerClips[index - 1][roll]);

                    lastPlayTime = Time.time;
                    minPlayGap = Random.Range(15.0f, 30.0f);
                }
            }
            else
            {
                if (SkillHitOtherClips[index - 1].Length > 0)
                {
                    var roll = Random.Range(0, SkillHitOtherClips[index - 1].Length - 1);
                    player.mainController.voiceSource.PlayOneShot(SkillHitOtherClips[index - 1][roll]);

                    lastPlayTime = Time.time;
                    minPlayGap = Random.Range(15.0f, 30.0f);
                }
            }
        }
    }
}