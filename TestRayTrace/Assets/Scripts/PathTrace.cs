using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
    public const int SPP = 64;
    public const int  BN = 1; //BounceNum >=1。为1时，从光源Bounce到surful反射进眼睛，是直接光。

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

    

    public ComputeShader cs;
    public RenderTexture rt;

    public int w = 1024;
    public int h = 720;

    Ray[] mainRays; //1pp
    Ray[] subRays; //64pp
    HitInfo[] mainHits; //1pp

    ComputeBuffer buffer_mainRays;
    ComputeBuffer buffer_subRays;
    ComputeBuffer buffer_mainHits;

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
        //for(int j=0;j<h;j++)
        //{
        //    for(int i=0;i<w;i++)
        //    {
        //        Ray ray = new Ray();
        //        ray.pos = new Vector3();
        //        ray.dir = new Vector3(1, 0, 0);
        //        mainRays[i + w * j] = ray;
        //        for(int inx=0;inx<SPP;inx++)
        //        {
        //            subRays[i + w * j] = ray;
        //        }
        //    }
        //}
    }


    void Trace()
    {
        //??? make sure has inited

       //ComputeBuffer buffer_rays = new ComputeBuffer(w * h, GetRayStride());
       //buffer_rays.SetData(rays);
       //
       //ComputeBuffer buffer_hitInfos = new ComputeBuffer(w * h, GetHitInfoStride());
       //buffer_hitInfos.SetData(hitInfos);
       //
       //int kInx = cs.FindKernel("Trace");
       //
       //cs.SetBuffer(kInx, "rays", buffer_rays);
       //cs.SetBuffer(kInx, "hitInfos", buffer_hitInfos);
       //cs.SetTexture(kInx, "Result", rt);
       //cs.SetFloat("w", w);
       //cs.SetFloat("h", h);
       //
       //cs.Dispatch(kInx, w / 8, h / 8, 1);
       //
       //buffer_rays.GetData(rays);      
       //buffer_rays.Dispose();
       //
       //buffer_hitInfos.GetData(hitInfos);
       //buffer_hitInfos.Dispose();
    }

    void Bounce()
    {
        //??? make sure has inited

        //ComputeBuffer buffer_rays = new ComputeBuffer(w * h, GetRayStride());
        //buffer_rays.SetData(rays);
        //
        //ComputeBuffer buffer_hitInfos = new ComputeBuffer(w * h, GetHitInfoStride());
        //buffer_hitInfos.SetData(hitInfos);
        //
        ////ComputeBuffer buffer_shadeTasks = new ComputeBuffer(w * h * TraceTime, GetShadeTaskStride());
        ////buffer_shadeTasks.SetData(shadeTasks);
        //
        //int kInx = cs.FindKernel("Bounce");
        //
        //cs.SetBuffer(kInx, "rays", buffer_rays);
        //cs.SetBuffer(kInx, "hitInfos", buffer_hitInfos);
        ////cs.SetBuffer(kInx, "shadeTasks", buffer_shadeTasks);
        //cs.SetTexture(kInx, "Result", rt);
        //cs.SetFloat("w", w);
        //cs.SetFloat("h", h);
        //
        //cs.Dispatch(kInx, w / 8, h / 8, 1);
        //
        //buffer_rays.GetData(rays);
        //buffer_rays.Dispose();
        //
        //buffer_hitInfos.GetData(hitInfos);
        //buffer_hitInfos.Dispose();

        //buffer_shadeTasks.GetData(shadeTasks);
        //buffer_shadeTasks.Dispose();
    }

    void Render()
    {
        //??? make sure has inited,bounced

        //ComputeBuffer buffer_rays = new ComputeBuffer(w * h, GetRayStride());
        //buffer_rays.SetData(rays);
        //
        //ComputeBuffer buffer_hitInfos = new ComputeBuffer(w * h, GetHitInfoStride());
        //buffer_hitInfos.SetData(hitInfos);
        //
        ////int kInx = cs.FindKernel("Render");
        //int kInx = cs.FindKernel("Render_MonteCarlo");
        //
        //cs.SetBuffer(kInx, "rays", buffer_rays);
        //cs.SetBuffer(kInx, "hitInfos", buffer_hitInfos);
        //cs.SetTexture(kInx, "Result", rt);
        //cs.SetFloat("w", w);
        //cs.SetFloat("h", h);
        //
        //cs.Dispatch(kInx, w / 8, h / 8, 1);
        //
        //buffer_rays.GetData(rays);
        //buffer_rays.Dispose();
        //
        //buffer_hitInfos.GetData(hitInfos);
        //buffer_hitInfos.Dispose();
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
        //ComputeBuffer buffer_mainHits = new ComputeBuffer(w * h, GetHitInfoStride());
        //buffer_mainHits.SetData(mainHits);
        //##################################
        //### compute
        int kInx = cs.FindKernel("InitRays");

        cs.SetBuffer(kInx, "mainRays", buffer_mainRays);
        cs.SetBuffer(kInx, "subRays", buffer_subRays);
        cs.SetBuffer(kInx, "mainHits", buffer_mainHits);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetFloat("w", w);
        cs.SetFloat("h", h);

        cs.Dispatch(kInx, w / 8, h / 8, 1);
        //### compute
        //#####################################
        PostComputeBuffer(ref buffer_mainRays, mainRays);
        PostComputeBuffer(ref buffer_subRays, subRays);
        PostComputeBuffer(ref buffer_mainHits, mainHits);
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
        //if (GUI.Button(new Rect(0, 50, 100, 50), "Trace"))
        //{
        //    Trace();
        //}
        //if (GUI.Button(new Rect(100, 50, 100, 50), "Bounce"))
        //{
        //    Bounce();
        //}
        //if (GUI.Button(new Rect(0, 100, 100, 50), "Render"))
        //{
        //    Render();
        //}
    }
}
