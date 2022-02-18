using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static CopyUtility;

public class FSRProcessor : ImgCSProcessor
{
    public string kernel2 = "RCAS";
    public float sharpness = 0.9f;
    public float scale = 2.0f;
    public RenderTexture easuRT;
    protected override void PrepareRT(ref Texture2D tex, ref RenderTexture rTex)
    {
        //Debug.Log("FSR Create RT");
        int w = (int)(tex.width * scale);
        int h = (int)(tex.height * scale);
        rTex = new RenderTexture(w, h, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        rTex.enableRandomWrite = true;

        rTex.Create();
    }

    protected override void Compute_Process(ref Texture2D tex, ref RenderTexture rTex)
    {
        Debug.Log("FSR Compute");
        base.Compute_Process(ref tex, ref easuRT);
        PrepareRT(ref tex, ref rt);
        int w = rt.width;
        int h = rt.height;
        int kInx = cs.FindKernel(kernel2);
        cs.SetTexture(kInx, "easuRT", easuRT);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetFloat("sharpness", sharpness);
        cs.Dispatch(kInx, w / 8, h / 8, 1);
    }
}