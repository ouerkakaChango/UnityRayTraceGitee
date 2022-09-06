using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace XCDeprecated
{
    public class testRT : MonoBehaviour
    {

        public struct Ray
        {
            public Vector3 pos;
            public Vector3 dir;
        }

        public struct HitInfo
        {
            public int bHit;
            public int obj;
            public Vector3 hitN;
            public Vector3 hitP;
        }

        public struct ShadeTask
        {
            public int obj;
            public Vector3 N;
            public Vector3 V;

            public Vector3[] Li;
            public Vector3[] L;
        }

        public int TraceTime = 2; //第一次Trace只看见自发光物体（光源），第二次看见光源照出的直接光，第三次包含间接光(2bounce)
        public const int SSP = 64;

        public ComputeShader cs;
        public RenderTexture rt;

        public int w = 1024;
        public int h = 720;

        private Ray[] rays;
        private HitInfo[] hitInfos;
        private ShadeTask[] shadeTasks;

        // Start is called before the first frame update
        void Start()
        {
        }

        // Update is called once per frame
        void Update()
        {

        }

        int GetRayStride()
        {//Ray
         //int colorSize = sizeof(float) * 4;
            int vector3Size = sizeof(float) * 3;
            return 2 * vector3Size;
        }

        int GetHitInfoStride()
        {//HitInfo
            int intSize = sizeof(int);
            int vector3Size = sizeof(float) * 3;
            return intSize * 2 + vector3Size * 2;
        }

        int GetShadeTaskStride()
        {//ShadeTask
            int intSize = sizeof(int);
            int vector3Size = sizeof(float) * 3;
            return intSize + vector3Size * 2 + vector3Size * SSP * 2;
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
            for (int j = 0; j < h; j++)
            {
                for (int i = 0; i < w; i++)
                {
                    CreateRay(i, j);
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

            //shadeTasks = new ShadeTask[w * h * TraceTime];
            //for (int k = 0; k < TraceTime; k++)
            //{
            //    for (int j = 0; j < h; j++)
            //    {
            //        for (int i = 0; i < w; i++)
            //        {
            //            CreateShadeTask(i, j, k);
            //        }
            //    }
            //}
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
            hitInfo.obj = -1;
            hitInfo.hitN = new Vector3(0, 0, 0);
            hitInfo.hitP = new Vector3(0, 0, 0);
            hitInfos[i + w * j] = hitInfo;
        }

        void CreateShadeTask(int i, int j, int k)
        {
            ShadeTask shadeTask = new ShadeTask();
            shadeTask.obj = -1;
            shadeTask.N = new Vector3();
            shadeTask.V = new Vector3();

            shadeTask.L = new Vector3[SSP];
            shadeTask.Li = new Vector3[SSP];
            shadeTasks[i + w * j + w * h * k] = shadeTask;
        }

        void Trace()
        {
            //??? make sure has inited

            ComputeBuffer buffer_rays = new ComputeBuffer(w * h, GetRayStride());
            buffer_rays.SetData(rays);

            ComputeBuffer buffer_hitInfos = new ComputeBuffer(w * h, GetHitInfoStride());
            buffer_hitInfos.SetData(hitInfos);

            int kInx = cs.FindKernel("Trace");

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

        void Bounce()
        {
            //??? make sure has inited

            ComputeBuffer buffer_rays = new ComputeBuffer(w * h, GetRayStride());
            buffer_rays.SetData(rays);

            ComputeBuffer buffer_hitInfos = new ComputeBuffer(w * h, GetHitInfoStride());
            buffer_hitInfos.SetData(hitInfos);

            //ComputeBuffer buffer_shadeTasks = new ComputeBuffer(w * h * TraceTime, GetShadeTaskStride());
            //buffer_shadeTasks.SetData(shadeTasks);

            int kInx = cs.FindKernel("Bounce");

            cs.SetBuffer(kInx, "rays", buffer_rays);
            cs.SetBuffer(kInx, "hitInfos", buffer_hitInfos);
            //cs.SetBuffer(kInx, "shadeTasks", buffer_shadeTasks);
            cs.SetTexture(kInx, "Result", rt);
            cs.SetFloat("w", w);
            cs.SetFloat("h", h);

            cs.Dispatch(kInx, w / 8, h / 8, 1);

            buffer_rays.GetData(rays);
            buffer_rays.Dispose();

            buffer_hitInfos.GetData(hitInfos);
            buffer_hitInfos.Dispose();

            //buffer_shadeTasks.GetData(shadeTasks);
            //buffer_shadeTasks.Dispose();
        }

        void Render()
        {
            //??? make sure has inited,bounced

            ComputeBuffer buffer_rays = new ComputeBuffer(w * h, GetRayStride());
            buffer_rays.SetData(rays);

            ComputeBuffer buffer_hitInfos = new ComputeBuffer(w * h, GetHitInfoStride());
            buffer_hitInfos.SetData(hitInfos);

            //int kInx = cs.FindKernel("Render");
            int kInx = cs.FindKernel("Render_MonteCarlo");

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
            if (GUI.Button(new Rect(0, 50, 100, 50), "Trace"))
            {
                Trace();
            }
            if (GUI.Button(new Rect(100, 50, 100, 50), "Bounce"))
            {
                Bounce();
            }
            if (GUI.Button(new Rect(0, 100, 100, 50), "Render"))
            {
                Render();
            }
        }
    }
}