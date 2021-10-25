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
    //根据网上资料，N卡最小也有32threads，A卡64
    //所以 Use 64 threads (e.g. (64, 1, 1), (8, 8, 1), (16, 2, 2) etc.)
    //threads数量过低会慢很多
    const int CoreX = 8;
    const int CoreY = 8;

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

    public int BN = 1; //BounceNum >=1。为1时，从光源Bounce到surful反射进眼睛，是直接光。
    int BI = 0; //now BounceInx

    public int w = 1024;
    public int h = 720;
    public int SPP = 32;
    public int SPP_cell = 16;

    public int wDivide = 2;
    public int hDivide = 2;
    int cw, ch;

    Ray[] mainRays; //1pp
    Ray[] subRays; //SPP pp
    HitInfo[] mainHits; //1pp
    HitInfo[] subHits;//BN per subRay == BN*SPP pp
    Light[] subLights;

    ComputeBuffer buffer_mainRays;
    ComputeBuffer buffer_subRays;
    ComputeBuffer buffer_mainHits;
    ComputeBuffer buffer_subHits;

    // Start is called before the first frame update
    void Start()
    {
        //DoPathTrace();
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
    }

    void DisposeRays()
    {
        buffer_mainRays .Dispose();
        buffer_subRays  .Dispose();
        buffer_mainHits .Dispose();
        buffer_subHits  .Dispose();
    }

    void CreateRaysBlock(int i,int j)
    {
        //if (i == 0 && j == 0)
        if(mainRays == null)
        {
            cw = w / wDivide;
            ch = h / hDivide;
            mainRays = new Ray[cw * ch];
            subRays = new Ray[cw * ch * SPP];
            mainHits = new HitInfo[cw * ch];
            subHits = new HitInfo[cw * ch * SPP * BN];
        }
    }

    void InitBlock(int i,int j)
    {
        BI = 0;
        CreateRaysBlock(i,j);
        Compute_InitRaysBlock(i, j);
    }

    void DoTraceBounceBlock(int i, int j)
    {
        TraceBlock(i, j);
        for(int inx=1;inx < BN;inx++)
        {
            BounceBlock(i,j);
            TraceBlock(i, j);
        }
    }

    void RenderBlock(int i, int j)
    {
        Compute_RenderBlock(i, j);
    }

    //#######################################

    static public void PreComputeRayBuffer(ref ComputeBuffer buffer, int count, Ray[] rays)
    {
        if (buffer != null)
        {
            return;
        }
        buffer = new ComputeBuffer(count, GetRayStride());
        buffer.SetData(rays); 
    }

    static public void PreComputeHitinfoBuffer(ref ComputeBuffer buffer, int count, HitInfo[] hits)
    {
        if (buffer != null)
        {
            return;
        }
        buffer = new ComputeBuffer(count, GetHitInfoStride());
        buffer.SetData(hits);
    }

    static public void PreComputeLightBuffer(ref ComputeBuffer buffer, int count, Light[] lights)
    {
        if (buffer != null)
        {
            return;
        }
        buffer = new ComputeBuffer(count, GetLightStride());
        buffer.SetData(lights);
    }

    static public void PostComputeBuffer(ref ComputeBuffer buffer,System.Array arr)
    {
        return;
        buffer.GetData(arr);
        buffer.Dispose();
    }

    void Compute_InitRaysBlock(int i,int j)
    {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
        }

        PreComputeRayBuffer(ref buffer_mainRays, cw * ch, mainRays);
        PreComputeRayBuffer(ref buffer_subRays, cw * ch * SPP, subRays);
        PreComputeHitinfoBuffer(ref buffer_mainHits, cw * ch, mainHits);
        //##################################
        //### compute
        int kInx = cs.FindKernel("InitRaysBlock");

        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);
        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "mainHits", buffer_mainHits);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetInt("cw", cw);
        cs.SetInt("ch", ch);
        cs.SetInt("blockX", i);
        cs.SetInt("blockY", j);
        cs.SetInt("SPP", SPP);

        cs.Dispatch(kInx, cw / CoreX, ch / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_mainRays, mainRays);
        PostComputeBuffer(ref buffer_subRays, subRays);
        PostComputeBuffer(ref buffer_mainHits, mainHits);
    }
    //#######################################################################################################################
    void TraceBlock(int i, int j)
    {
        for (int traceInx = 0; traceInx < SPP / SPP_cell; traceInx++)
        {
            Compute_TraceBlock(traceInx, i, j);
        }
    }

    void Compute_TraceBlock(int traceInx, int i, int j)
    {
        //??? make sure has inited

        PreComputeRayBuffer(ref buffer_subRays, cw * ch * SPP, subRays);
        PreComputeHitinfoBuffer(ref buffer_subHits, cw * ch * SPP * BN, subHits);
        //##################################
        //### compute
        int kInx = cs.FindKernel("TraceBlock");

        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "subHits", buffer_subHits);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetInt("cw", cw);
        cs.SetInt("ch", ch);
        cs.SetInt("blockX", i);
        cs.SetInt("blockY", j);
        cs.SetInt("SPP", SPP);
        cs.SetInt("BI", BI);
        cs.SetInt("traceInx", traceInx);
        cs.SetInt("SPP_cell", SPP_cell);

        cs.Dispatch(kInx, cw / CoreX, ch / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_subRays, subRays);
        PostComputeBuffer(ref buffer_subHits, subHits);
    }
    //#######################################################################################################################
    void BounceBlock(int i,int j)
    {
        Compute_BounceBlock(i,j);
    }
    void Compute_BounceBlock(int i, int j)
    {
        //??? make sure has inited
        PreComputeRayBuffer(ref buffer_subRays, cw * ch * SPP, subRays);
        PreComputeHitinfoBuffer(ref buffer_subHits, cw * ch * SPP * BN, subHits);
        //##################################
        //### compute
        int kInx = cs.FindKernel("BounceBlock");

        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "subHits", buffer_subHits);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetInt("cw", cw);
        cs.SetInt("ch", ch);
        cs.SetInt("blockX", i);
        cs.SetInt("blockY", j);
        cs.SetInt("BI", BI);
        cs.SetInt("SPP", SPP);

        cs.Dispatch(kInx, cw / CoreX, ch / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_subRays, subRays);
        PostComputeBuffer(ref buffer_subHits, subHits);

        BI += 1;
    }

    void Compute_RenderBlock(int i, int j)
    {
        //??? make sure has inited

        PreComputeRayBuffer(ref buffer_mainRays, cw * ch, mainRays);
        PreComputeRayBuffer(ref buffer_subRays, cw * ch * SPP, subRays);
        PreComputeHitinfoBuffer(ref buffer_mainHits, cw * ch, mainHits);
        PreComputeHitinfoBuffer(ref buffer_subHits, cw * ch * SPP * BN, subHits);
        //##################################
        //### compute
        int kInx = cs.FindKernel("RenderBlock");

        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);
        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "mainHits", buffer_mainHits);
        cs.SetBuffer(kInx, "subHits", buffer_subHits);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetInt("cw", cw);
        cs.SetInt("ch", ch);
        cs.SetInt("blockX", i);
        cs.SetInt("blockY", j);
        cs.SetInt("BI", BI);
        cs.SetInt("SPP", SPP);

        cs.Dispatch(kInx, cw / CoreX, ch / CoreY, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_mainRays, mainRays);
        PostComputeBuffer(ref buffer_subRays, subRays);
        PostComputeBuffer(ref buffer_mainHits, mainHits);
        PostComputeBuffer(ref buffer_subHits, subHits);
    }

    void PathTraceBlock(int i, int j)
    {
        InitBlock(i, j);
        DoTraceBounceBlock(i, j);
        RenderBlock(i, j);

        //InitBlock(0, 0);
        //TraceBlock(0, 0);
        //BounceBlock(0, 0);
        //TraceBlock(0, 0);
    }

    void DoPathTrace()
    {
        for(int j=0;j<hDivide;j++)
        {
            for(int i=0;i<wDivide;i++)
            {
                PathTraceBlock(i, j);
            }
        }
        DisposeRays();
    }

    void Filter()
    {
        Compute_Filter();
    }

    void Compute_Filter()
    {
        //##################################
        //### compute
        int kInx = cs.FindKernel("Filter");

        cs.SetTexture(kInx, "Result", rt);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################
    }

    //@@@
    private void OnGUI()
    {
        if (GUI.Button(new Rect(0, 50, 100, 50), "Do"))
        {
            DoPathTrace();
        }
        if (GUI.Button(new Rect(0, 50*2, 100, 50), "Filter"))
        {
            Filter();
        }
    }
}
