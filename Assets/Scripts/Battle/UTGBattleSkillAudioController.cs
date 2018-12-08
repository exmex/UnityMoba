using System.Collections.Generic;
using UnityEngine;
using System.Collections;

public class UTGBattleSkillAudioController : MonoBehaviour
{
    public AudioClip e0;
    public AudioClip ea;
    public AudioClip eb;
    public AudioClip ec;
    public AudioClip ed;
    public AudioClip ef;

    public ArrayList audioList;

    private AudioSource CreateSource(Transform fx, AudioClip clip)
    {
        var audio = fx.gameObject.AddComponent<AudioSource>();
        audio.playOnAwake = false;
        audio.rolloffMode = AudioRolloffMode.Linear;
        audio.spatialBlend = 1.0f;
        audio.maxDistance = 8.0f;
        audio.clip = clip;

        audioList.Add(audio);

        return audio;
    }

    public void Init()
    {
        audioList = new ArrayList();
    }

    public void Reset()
    {
        foreach (AudioSource o in audioList)
        {
            if (o != null)
            {
                o.Stop();
                Destroy(o);
            }
        }
    }

    public void FXE0(Transform fx)
    {
        if (e0 == null)
            return;

        CreateSource(fx, e0).Play();
    }

    public void FXEA(Transform fx)
    {
        if (ea == null)
            return;

        CreateSource(fx, ea).Play();
    }

    public AudioSource EbSource;

    public void FXEB(Transform fx)
    {
        if (eb == null)
            return;

        EbSource = CreateSource(fx, eb);
        EbSource.Play();
    }

    public void FXEBStop()
    {
        //if (EbSource != null)
        //    EbSource.Stop();
    }

    public void FXExplode(Transform fx)
    {
        if (ef == null)
            return;

        CreateSource(fx, ef).Play();
    }


    public void FXEC(Transform fx)
    {
        if (ec == null)
            return;

        CreateSource(fx, ec).Play();
    }

    public void FXED(Transform fx)
    {
        if (ed == null)
            return;

        CreateSource(fx, ed).Play();
    }
}