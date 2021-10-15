using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//pp == per pixel 
//SPP=64,BN=BounceNum
//生成MainRay 1(逐像素),生成HitInfo mainhit(逐像素)
//BounceMain 在第一次surful上反射（均匀采样），生成SubRay subray[SPP](逐像素)
//BounceSub HitInfo subhit[BN](逐SubRay)

//GatherRender 
//生成   LightInfo mainLight[64]（逐像素/MainRay）
//生成   LightInfo subLight[BN]（逐SubRay）
//Render 逐SubRay，从后到前，subhit[BN]=》subLight[BN]
//                           inx=BN-1,subLight=subhit物体材质的emissive
//                           subLight[x-1] = BRDF(subLight[x],subhit[x-1])
//逐MainRay  forloop(64): result += BRDF(subLight[subRayInx][0],mainhit[subRayInx].dir/length)

public class PathTrace : MonoBehaviour
{
    public const int  BN = 1; //BounceNum >=1。为1时，从光源Bounce到surful反射进眼睛，是直接光。
    int BI = 0; //now BounceInx

    public struct HitInfo
    {
        public int bHit;
        public int obj;
        public Vector3 N;
        public Vector3 P;
    }

    public struct Ray
    {
        public Vector3 pos;
        public Vector3 dir;
    }

    public struct Light
    {
        public Vector3 color;
    }

    public ComputeShader cs;
    public RenderTexture rt;

    public int w = 1024;
    public int h = 720;
    public int SPP = 16;

    Ray[] mainRays; //1pp
    Ray[] subRays; //64pp
    HitInfo[] mainHits; //1pp
    HitInfo[] subHits;//BN per subRay == BN*SPP pp
    Light[] subLights;

    ComputeBuffer buffer_mainRays;
    ComputeBuffer buffer_subRays;
    ComputeBuffer buffer_mainHits;
    ComputeBuffer buffer_subHits;
    ComputeBuffer buffer_subLights;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {

    }

    static public int GetRayStride()
    {//Ray
     //int colorSize = sizeof(float) * 4;
        int vector3Size = sizeof(float) * 3;
        return 2 * vector3Size;
    }

    static public int GetHitInfoStride()
    {//HitInfo
        int intSize = sizeof(int);
        int vector3Size = sizeof(float) * 3;
        return intSize * 2 + vector3Size * 2;
    }

    static public int GetLightStride()
    {//Light
        int vector3Size = sizeof(float) * 3;
        return vector3Size;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
   {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
        }
        Graphics.Blit(rt, destination);
    }

    void CreateRays()
    {
        mainRays = new Ray[w * h];
        subRays = new Ray[w * h * SPP];
        mainHits = new HitInfo[w * h];
        subHits = new HitInfo[w * h * SPP * BN];
        subLights = new Light[w * h * SPP];
    }

    static public void PreComputeRayBuffer(ref ComputeBuffer buffer, int count, Ray[] rays)
    {
        buffer = new ComputeBuffer(count, GetRayStride());
        buffer.SetData(rays);
    }

    static public void PreComputeHitinfoBuffer(ref ComputeBuffer buffer, int count, HitInfo[] hits)
    {
        buffer = new ComputeBuffer(count, GetHitInfoStride());
        buffer.SetData(hits);
    }

    static public void PreComputeLightBuffer(ref ComputeBuffer buffer, int count, Light[] lights)
    {
        buffer = new ComputeBuffer(count, GetLightStride());
        buffer.SetData(lights);
    }

    static public void PostComputeBuffer(ref ComputeBuffer buffer,System.Array arr)
    {
        buffer.GetData(arr);
        buffer.Dispose();
    }

    void InitRays()
    {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
        }

        PreComputeRayBuffer(ref buffer_mainRays, w * h, mainRays);
        PreComputeRayBuffer(ref buffer_subRays, w * h * SPP, subRays);
        PreComputeHitinfoBuffer(ref buffer_mainHits, w * h, mainHits);
        //##################################
        //### compute
        int kInx = cs.FindKernel("InitRays");

        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);
        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "mainHits", buffer_mainHits);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetFloat("w", w);
        cs.SetFloat("h", h);
        cs.SetInt("SPP", SPP);

        cs.Dispatch(kInx, w / 8, h / 8, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_mainRays, mainRays);
        PostComputeBuffer(ref buffer_subRays, subRays);
        PostComputeBuffer(ref buffer_mainHits, mainHits);
    }

    //??? 现在spp为16， 32就不行了，像是Unity的显存支持不够
    //之后尝试分16为一组，分块顺序ComputeTrace。
    void Trace()
    {
        //??? make sure has inited

        PreComputeRayBuffer(ref buffer_subRays, w * h * SPP, subRays);
        PreComputeHitinfoBuffer(ref buffer_subHits, w * h * SPP * BN, subHits);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Trace");

        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "subHits", buffer_subHits);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetFloat("w", w);
        cs.SetFloat("h", h);
        cs.SetFloat("BI", BI);
        cs.SetInt("SPP", SPP);

        cs.Dispatch(kInx, w / 8, h / 8, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_subRays, subRays);
        PostComputeBuffer(ref buffer_subHits, subHits);
    }

    void Bounce()
    {
        //??? make sure has inited
        PreComputeRayBuffer(ref buffer_subRays, w * h * SPP, subRays);
        PreComputeHitinfoBuffer(ref buffer_subHits, w * h * SPP * BN, subHits);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Bounce");

        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "subHits", buffer_subHits);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetFloat("w", w);
        cs.SetFloat("h", h);
        cs.SetFloat("BI", BI);
        cs.SetInt("SPP", SPP);

        cs.Dispatch(kInx, w / 8, h / 8, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_subRays, subRays);
        PostComputeBuffer(ref buffer_subHits, subHits);

        BI += 1;
    }

    void Compute_GatherSublight()
    {
        //??? make sure has inited
        PreComputeRayBuffer(ref buffer_subRays, w * h * SPP, subRays);
        PreComputeHitinfoBuffer(ref buffer_subHits, w * h * SPP * BN, subHits);
        PreComputeLightBuffer(ref buffer_subLights, w * h * SPP, subLights);
        //##################################
        //### compute
        int kInx = cs.FindKernel("GatherSublight");

        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "subHits", buffer_subHits);
        cs.SetBuffer(kInx, "subLights", buffer_subLights);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetFloat("w", w);
        cs.SetFloat("h", h);
        cs.SetFloat("BI", BI);
        cs.SetInt("SPP", SPP);

        cs.Dispatch(kInx, w / 8, h / 8, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_subRays, subRays);
        PostComputeBuffer(ref buffer_subHits, subHits);
        PostComputeBuffer(ref buffer_subLights, subLights);
    }

    void Render()
    {
        Compute_GatherSublight();
    }

    //@@@
    private void OnGUI()
    {
        GUI.Label(new Rect(0, 0, 200, 50), "Total BounceNum: " + BN);
        if (GUI.Button(new Rect(0, 50, 100, 50), "Init"))
        {
            CreateRays();
            InitRays();
        } 
        if (GUI.Button(new Rect(0, 100, 100, 50), "Trace"))
        {
            Trace();
        }
        if (GUI.Button(new Rect(100, 100, 100, 50), "Bounce"))
        {
            Bounce();
        }
        if (GUI.Button(new Rect(0, 150, 100, 50), "Render"))
        {
            Render();
        }
    }
}
