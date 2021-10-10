using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct Ray
{
    public Vector3 pos;
    public Vector3 dir;
}

public struct HitInfo
{
    public int bHit;
    public Vector3 hitN;
}

public class testRT : MonoBehaviour
{
    public ComputeShader cs;
    public RenderTexture rt;

    public int w = 1024;
    public int h = 720;

    private Ray[] rays;
    private HitInfo[] hitInfos;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {

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
        rays = new Ray[w * h];
        for(int j=0;j<h;j++)
        {
            for(int i=0;i<w;i++)
            {
                CreateRay(i,j);
            }
        }

        hitInfos = new HitInfo[w * h];
        for (int j = 0; j < h; j++)
        {
            for (int i = 0; i < w; i++)
            {
                CreateHitInfo(i, j);
            }
        }
    }

    void CreateRay(int i, int j)
    {
        Ray ray = new Ray();
        ray.pos = new Vector3();
        ray.dir = new Vector3(1, 0, 0);
        rays[i + w * j] = ray;
    }

    void CreateHitInfo(int i, int j)
    {
        HitInfo hitInfo = new HitInfo();
        hitInfo.bHit = 0;
        hitInfo.hitN = new Vector3(0, 0, 0);
        hitInfos[i + w * j] = hitInfo;
    }

    int GetRayStride()
    {
        //int colorSize = sizeof(float) * 4;
        int vector3Size = sizeof(float) * 3;
        return 2 * vector3Size;
    }

    int GetHitInfoStride()
    {
        int intSize = sizeof(int);
        int vector3Size = sizeof(float) * 3;
        return intSize + vector3Size;
    }

    void Bounce()
    {
        //??? make sure has inited

        ComputeBuffer buffer_rays = new ComputeBuffer(w * h, GetRayStride());
        buffer_rays.SetData(rays);

        ComputeBuffer buffer_hitInfos = new ComputeBuffer(w * h, GetHitInfoStride());
        buffer_hitInfos.SetData(hitInfos);

        int kInx = cs.FindKernel("Bounce");

        cs.SetBuffer(kInx, "rays", buffer_rays);
        cs.SetBuffer(kInx, "hitInfos", buffer_hitInfos);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetFloat("w", w);
        cs.SetFloat("h", h);
        
        cs.Dispatch(kInx, w / 8, h / 8, 1);
        
        buffer_rays.GetData(rays);      
        buffer_rays.Dispose();

        buffer_hitInfos.GetData(hitInfos);
        buffer_hitInfos.Dispose();
    }

    void Render()
    {
        //??? make sure has inited,bounced

        ComputeBuffer buffer_rays = new ComputeBuffer(w * h, GetRayStride());
        buffer_rays.SetData(rays);

        ComputeBuffer buffer_hitInfos = new ComputeBuffer(w * h, GetHitInfoStride());
        buffer_hitInfos.SetData(hitInfos);

        int kInx = cs.FindKernel("Render");

        cs.SetBuffer(kInx, "rays", buffer_rays);
        cs.SetBuffer(kInx, "hitInfos", buffer_hitInfos);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetFloat("w", w);
        cs.SetFloat("h", h);

        cs.Dispatch(kInx, w / 8, h / 8, 1);

        buffer_rays.GetData(rays);
        buffer_rays.Dispose();

        buffer_hitInfos.GetData(hitInfos);
        buffer_hitInfos.Dispose();
    }

    void InitRays()
    {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
        }

        ComputeBuffer buffer_rays = new ComputeBuffer(w * h, GetRayStride());
        buffer_rays.SetData(rays);

        int kInx = cs.FindKernel("InitRays");

        cs.SetBuffer(kInx, "rays", buffer_rays);
        cs.SetTexture(kInx, "Result", rt);
        cs.SetFloat("w", w);
        cs.SetFloat("h", h);

        cs.Dispatch(kInx, w / 8, h / 8, 1);

        buffer_rays.GetData(rays);

        buffer_rays.Dispose();
    }

    //@@@
    private void OnGUI()
    {
        if (GUI.Button(new Rect(0, 0, 100, 50), "Init"))
        {
            CreateRays();
            InitRays();
        } 
        if (GUI.Button(new Rect(0, 50, 100, 50), "Bounce"))
        {
            Bounce();
        }
        if (GUI.Button(new Rect(0, 100, 100, 50), "Render"))
        {
            Render();
        }
    }
}
