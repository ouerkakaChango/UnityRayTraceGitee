using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IBLSpecBaker : MonoBehaviour
{
    public ComputeShader cs;

    public string saveFolder = "Assets";
    public int IterNum = 1;
    public int nowIter = 0;

    const int CoreX = 8;
    const int CoreY = 8;

    public Texture2D envRefTex;
    public RenderTexture outRT = null;
    int w, h;
    // Start is called before the first frame update
    void Start()
    {
        w = envRefTex.width;
        h = envRefTex.height;
        Debug.Log("envRef "+w+" "+h);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    //####################################################################################
    void Compute_Bake()
    {
        //##################################
        //### compute
        int kInx = cs.FindKernel("Bake");

        cs.SetTexture(kInx, "envRefTex", envRefTex);
        cs.SetTexture(kInx, "outRT", outRT);
        cs.SetInt("w", w);
        cs.SetInt("h", h);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
    }
    //####################################################################################
    void Init()
    {
        if (outRT == null)
        {
            outRT = new RenderTexture(w, h, 24);
            outRT.enableRandomWrite = true;
            outRT.Create();
        }
    }

    void DoBake()
    {
        Init();
        Compute_Bake();
    }

    void Export()
    {
        var tex = RT2Tex2D(outRT, TextureFormat.RGBAFloat);
        System.IO.File.WriteAllBytes(saveFolder+"/IBLSpecTest.exr", tex.EncodeToEXR());
    }

    static public Texture2D RT2Tex2D_unreliable(RenderTexture rTex, TextureFormat format = TextureFormat.RGBA32)
    {
        Texture2D dest = new Texture2D(rTex.width, rTex.height, format, false);
        dest.Apply(false);
        Graphics.CopyTexture(rTex, dest);
        return dest;
    }

    Texture2D RT2Tex2D(RenderTexture rTex, TextureFormat format = TextureFormat.RGBA32)
    {
        Texture2D tex = new Texture2D(rTex.width, rTex.height, format, false);
        RenderTexture.active = rTex;
        tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
        tex.Apply();

        return tex;
    }
    //####################################################################################

    IEnumerator Co_GoIter;
    //@@@
    private void OnGUI()
    {
        if (GUI.Button(new Rect(0, 0, 100, 50), "GoBake!"))
        {
            Co_GoIter = GoIter();
            StartCoroutine(Co_GoIter);
        }
    }

    IEnumerator GoIter()
    {
        while (nowIter < IterNum)
        {
            DoBake();
            nowIter++;
            if(nowIter == IterNum)
            {
                Export();
            }
            yield return null;
        }
    }
}
