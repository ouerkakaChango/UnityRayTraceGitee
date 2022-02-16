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

    public struct PathInfo
    {
        public int hasEnd; //没打中东西||已经打中灯光
        public int endInx; //最后一次hit中时的BI
    }

    public ComputeShader cs;
    public RenderTexture rt;
    public RenderTexture final_rt;

    public int IterNum = 400;
    public int nowIter = 0;

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
    PathInfo[] mainPaths;//1 pp
    PathInfo[] subPaths;//SPP pp

    ComputeBuffer buffer_mainRays;
    ComputeBuffer buffer_subRays;
    ComputeBuffer buffer_mainHits;
    ComputeBuffer buffer_subHits;
    ComputeBuffer buffer_mainPaths;
    ComputeBuffer buffer_subPaths;

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

    static public int GetPathInfoStride()
    {//PathInfo
        int intSize = sizeof(int);
        return intSize*2;
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

    void DisposeRays()
    {
        if (buffer_mainRays != null)
        {
            buffer_mainRays.Dispose();
        }
        if (buffer_mainHits != null)
        {
            buffer_mainHits.Dispose();
        }
        if (buffer_subRays != null)
        {
            buffer_subRays.Dispose();
        }
        if (buffer_subHits != null)
        {
            buffer_subHits.Dispose();
        }
        if (buffer_mainPaths!=null)
        {
            buffer_mainPaths.Dispose();
        }
        if (buffer_subPaths!=null)
        {
            buffer_subPaths.Dispose();
        }
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
            mainPaths = new PathInfo[cw * ch];
            subPaths = new PathInfo[cw * ch * SPP];
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

    static public void PreComputePathinfoBuffer(ref ComputeBuffer buffer, int count, PathInfo[] pathInfos)
    {
        if (buffer != null)
        {
            return;
        }
        buffer = new ComputeBuffer(count, GetPathInfoStride());
        buffer.SetData(pathInfos);
    }

    static public void PostComputeBuffer(ref ComputeBuffer buffer,System.Array arr)
    {
        return;
        //buffer.GetData(arr);
        //buffer.Dispose();
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

        PreComputePathinfoBuffer(ref buffer_mainPaths, cw * ch, mainPaths);
        PreComputePathinfoBuffer(ref buffer_subPaths, cw * ch * SPP, subPaths);
        //##################################
        //### compute
        int kInx = cs.FindKernel("InitRaysBlock");

        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);
        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "mainHits", buffer_mainHits);

        cs.SetBuffer(kInx, "mainPaths", buffer_mainPaths);
        cs.SetBuffer(kInx, "subPaths", buffer_subPaths);

        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("nowIter", nowIter);
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

        PostComputeBuffer(ref buffer_mainPaths, mainPaths);
        PostComputeBuffer(ref buffer_subPaths, subPaths);
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

        PreComputePathinfoBuffer(ref buffer_mainPaths, cw * ch, mainPaths);
        PreComputePathinfoBuffer(ref buffer_subPaths, cw * ch * SPP, subPaths);
        //##################################
        //### compute
        int kInx = cs.FindKernel("TraceBlock");

        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "subHits", buffer_subHits);

        cs.SetBuffer(kInx, "mainPaths", buffer_mainPaths);
        cs.SetBuffer(kInx, "subPaths", buffer_subPaths);

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

        PostComputeBuffer(ref buffer_mainPaths, mainPaths);
        PostComputeBuffer(ref buffer_subPaths, subPaths);
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

        PreComputePathinfoBuffer(ref buffer_mainPaths, cw * ch, mainPaths);
        PreComputePathinfoBuffer(ref buffer_subPaths, cw * ch * SPP, subPaths);
        //##################################
        //### compute
        int kInx = cs.FindKernel("BounceBlock");

        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "subHits", buffer_subHits);

        cs.SetBuffer(kInx, "mainPaths", buffer_mainPaths);
        cs.SetBuffer(kInx, "subPaths", buffer_subPaths);

        cs.SetTexture(kInx, "Result", rt);
        cs.SetInt("nowIter", nowIter);
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

        PostComputeBuffer(ref buffer_mainPaths, mainPaths);
        PostComputeBuffer(ref buffer_subPaths, subPaths);

        BI += 1;
    }

    void Compute_RenderBlock(int i, int j)
    {
        //??? make sure has inited

        PreComputeRayBuffer(ref buffer_mainRays, cw * ch, mainRays);
        PreComputeRayBuffer(ref buffer_subRays, cw * ch * SPP, subRays);
        PreComputeHitinfoBuffer(ref buffer_mainHits, cw * ch, mainHits);
        PreComputeHitinfoBuffer(ref buffer_subHits, cw * ch * SPP * BN, subHits);

        PreComputePathinfoBuffer(ref buffer_mainPaths, cw * ch, mainPaths);
        PreComputePathinfoBuffer(ref buffer_subPaths, cw * ch * SPP, subPaths);
        //##################################
        //### compute
        int kInx = cs.FindKernel("RenderBlock");

        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);
        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "mainHits", buffer_mainHits);
        cs.SetBuffer(kInx, "subHits", buffer_subHits);

        cs.SetBuffer(kInx, "mainPaths", buffer_mainPaths);
        cs.SetBuffer(kInx, "subPaths", buffer_subPaths);

        //!!!
        cs.SetTexture(kInx, "Result", final_rt);
        cs.SetInt("nowIter", nowIter);
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

        PostComputeBuffer(ref buffer_mainPaths, mainPaths);
        PostComputeBuffer(ref buffer_subPaths, subPaths);
    }

    //###
    void PathTraceBlock(int i, int j)
    {
        InitBlock(i, j);
        DoTraceBounceBlock(i, j);
        RenderBlock(i, j);

        //InitBlock(0, 0);
        //TraceBlock(0, 0);
        //BounceBlock(0, 0);
        //TraceBlock(0, 0);
        //RenderBlock(0, 0);
    }

    void DoPathTrace()
    {
        if (final_rt == null)
        {
            final_rt = new RenderTexture(w, h, 24);
            final_rt.enableRandomWrite = true;
            final_rt.Create();
        }

        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
        }

        for (int j=0;j<hDivide;j++)
        {
            for(int i=0;i<wDivide;i++)
            {
                PathTraceBlock(i, j);
            }
        }
        //!!!
        Graphics.Blit(final_rt, rt);
        if (nowIter == IterNum)
        {
            DisposeRays();
        }
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

    IEnumerator Co_GoIter;
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

        if (GUI.Button(new Rect(100, 50, 100, 50), "AddIteration"))
        {
            nowIter++;
        }

        if (GUI.Button(new Rect(100, 50*2, 100, 50), "GoIter!"))
        {
            Co_GoIter = GoIter();
            StartCoroutine(Co_GoIter);
        }
    }

    IEnumerator GoIter()
    {
        for (; nowIter < IterNum;)
        {
            //yield return new WaitForEndOfFrame();
            DoPathTrace();
            nowIter++;
            yield return null;
            //yield return new WaitForSeconds(0.1f);
        }
    }

    //IEnumerator OnPostRender()
    //{
    //    if (rt == null)
    //    {
    //        rt = new RenderTexture(w, h, 24);
    //        rt.enableRandomWrite = true;
    //        rt.Create();
    //    }
    //
    //    yield return new WaitForEndOfFrame();
    //    var cam = GetComponent<Camera>();
    //    var cameraViewRect = new Rect(cam.rect.xMin * Screen.width, Screen.height - cam.rect.yMax * Screen.height, cam.pixelWidth, cam.pixelHeight);
    //    Graphics.DrawTexture(cameraViewRect, rt);
    //}
}
