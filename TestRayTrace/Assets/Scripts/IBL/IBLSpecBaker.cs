using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TextureHelper;

public class IBLSpecBaker : MonoBehaviour
{
    public string outName = "IBLSpecTest";
    public ComputeShader cs;
    public int gammaMode = 0; //0:Do pow2.2 gamma 1:not gamma
    public int SPP = 10240;
    public float bakeRough = 0.25f;
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
        cs.SetInt("gammaMode", gammaMode);
        cs.SetInt("SPP", SPP);
        cs.SetFloat("bakeRough", bakeRough);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
    }
    //####################################################################################
    void Init()
    {
        w = envRefTex.width;
        h = envRefTex.height;
        if (w != h * 2)
        {
            Debug.Log("Warning: envTex w not h*2, bake may not accurate, because CS_IBLSpecBaker.compute not accurate calculate ellipse surface area");
        }
        if (outRT == null)
        {
            //### 一定要声明为ARGBFloat，才能被computeshader输出大于1的值
            outRT = new RenderTexture(w, h, 24, RenderTextureFormat.ARGBFloat);
            outRT.enableRandomWrite = true;
            outRT.Create();
        }
    }

    void DebugHDRImg(Texture2D hdrImg)
    {
        int c = 0;
        var colors = hdrImg.GetPixels();
        foreach (var pix in colors)
        {
            if (pix.r > 1)
            {
                Debug.Log(pix);
                c += 1;
            }

            if (c == 100)
            {
                break;
            }
        }
    }

    void Export()
    {
        var tex = RT2Tex2D(outRT, TextureFormat.RGBAFloat);
        //DebugHDRImg(tex);
        System.IO.File.WriteAllBytes(saveFolder+"/"+ outName +"_"+bakeRough.ToString("f2") + ".exr", tex.EncodeToEXR());
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
            Init();
            Compute_Bake();
            nowIter++;
            if(nowIter == IterNum)
            {
                Export();
            }
            yield return null;
        }
    }

    public void BakeSingle()
    {
        //Debug.Log("envRef " + w + " " + h);
        Init();
        Compute_Bake();
        Export();
    }

    public void Bake_AverageDelta(ref Texture2D[] outTexs,float deltaRoughness=0.25f)
    {
        Init();
        int texCount = (int)(1.0f / deltaRoughness) + 1;
        outTexs = new Texture2D[texCount];
        for (int i=0;i<texCount;i++)
        {
            float r = i * deltaRoughness;
            Debug.Log("Bake IBL roughness = "+r.ToString("f2"));
            bakeRough = r;
            //因为现在是从SDFGameEnvBaker里bake出的线性texture，所以不需要做gamma
            gammaMode = 1;
            Compute_Bake();
            TexHelper.RT2Tex2D(ref outTexs[i], ref outRT);
        }
        Debug.Log("Bake IBL done ");
    }

    public void UseDefaultBakeCS()
    {
        cs = Resources.Load<ComputeShader>("BakeCS/CS_IBLSpecBaker");
    }
}
