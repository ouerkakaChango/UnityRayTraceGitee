using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static CopyUtility;

public class FSRProcessor : ImgCSProcessor
{
    protected override void PrepareRT(ref Texture2D tex)
    {
        Debug.Log("FSR Create RT");
        int w = tex.width * 2;
        int h = tex.height * 2;
        rt = new RenderTexture(w, h, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        rt.enableRandomWrite = true;

        rt.Create();
    }
}
