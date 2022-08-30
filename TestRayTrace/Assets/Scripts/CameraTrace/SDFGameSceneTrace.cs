﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Ray = FastGeo.Ray;
using Debugger;
using static StringTool.StringHelper;

[ExecuteInEditMode]
public class SDFGameSceneTrace : MonoBehaviour
{
    struct MeshInfo
    {
        public Matrix4x4 localToWorldMatrix;
    };

    const int CoreX = 8;
    const int CoreY = 8;

    RenderTexture rt;
    RenderTexture easuRT,finalRT;
    public bool useFSR = true;
    public float FSR_Scale = 2.0f;

    public string SceneName = "Detail1";
    public AutoCS autoCS;
    ComputeShader cs;
    ComputeShader cs_FSR;
    public Texture2DArray envSpecTex2DArr;
    public Texture2D envBgTex;

    public int w = 1024;
    public int h = 720;

    Vector3 eyePos;
    Vector3 screenLeftDownPix;
    Vector3 screenU;
    Vector3 screenV;
    float pixW;
    float pixH;

    float daoScale = 1.0f;

    //Tools for Screen show
    float fps = 0;
    TimeLogger fpsTimer = new TimeLogger("fps");

    bool hasInited = false;

    void Start()
    {
        if (Application.isEditor && !Application.isPlaying)
        {
            //do what you want
            //RefreshAutoCS();
        }
        else
        {
            QualitySettings.vSyncCount = 1;
            UpdateCamParam();
            Co_GoIter = GoIter();
            StartCoroutine(Co_GoIter);
        }
    }

    void Update()
    {
        if (Input.GetKeyDown("q"))
        {
            daoScale *= 0.5f;
        }
        
        if (Input.GetKeyDown("e"))
        {
            daoScale *= 2.0f;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (rt == null)
        {
            return;
        }
        if (useFSR)
        {
            FSRProcessor.ProcessRT(ref cs_FSR, ref rt, ref easuRT, ref finalRT);
            Graphics.Blit(finalRT, destination);
        }
        else
        {
            Graphics.Blit(rt, destination);
        }
    }

    private void OnDisable()
    {
        //SafeDispose(buffer_tris);
    }

    //##################################################################################################
    void UpdateCamParam()
    {
        var cam = gameObject.GetComponent<Camera>();
        var near = cam.nearClipPlane;
        near *= daoScale;
        //var far = cam.farClipPlane;

        var camPos = gameObject.transform.position;
        var camForward = gameObject.transform.forward;
        eyePos = camPos;
        var screenPos = camPos + near * camForward;
        screenU = gameObject.transform.right;
        screenV = gameObject.transform.up;

        //大概在Unity场景中对比了一下渲染大小，定下了合理的像素晶元大小（也就是根据了w,h和原始的cam nf,FOV,尝试出合适的pixW）
        pixW = 0.000485f;
        pixH = pixW;
        pixW *= daoScale;
        pixH *= daoScale;
        screenLeftDownPix = screenPos + screenU * (-w / 2.0f + 0.5f) * pixW + screenV * (-h / 2.0f + 0.5f) * pixH;
    }

    static public void PreComputeBuffer(ref ComputeBuffer buffer, int stride, in System.Array dataArr)
    {
        if (buffer != null)
        {
            return;
        }
        buffer = new ComputeBuffer(dataArr.Length, stride);
        buffer.SetData(dataArr);
    }

    static public void PostComputeBuffer(ref ComputeBuffer buffer, System.Array arr)
    {
        return;
        //buffer.GetData(arr);
        //buffer.Dispose();
    }


    static public int GetRayStride()
    {
        int vec3Size = sizeof(float) * 3;
        return 2 * vec3Size;
    }
    //################################################################################################################
    void Compute_Render()
    {
        if(!hasInited)
        {
            return;
        }

        //PreComputeBuffer(ref buffer_vertices, sizeof(float) * 3, vertices);
        //##################################
        //### compute
        int kInx = cs.FindKernel("Render");

        //####
        //System Value
        cs.SetFloat("daoScale", daoScale);
        cs.SetVector("_Time", Shader.GetGlobalVector("_Time"));
        cs.SetTexture(kInx, "NoiseRGBTex", ShaderToyTool.Instance.noiseRGB);
        cs.SetTexture(kInx, "LUT_BRDF", ShaderToyTool.Instance.LUT_BRDF);
        cs.SetTexture(kInx, "perlinNoise1", ShaderToyTool.Instance.perlinNoise1);
        cs.SetTexture(kInx, "voronoiNoise1", ShaderToyTool.Instance.voronoiNoise1);
        for (int i=0;i<autoCS.texSys.outTextures.Count;i++)
        {
            cs.SetTexture(kInx, autoCS.texSys.outTextures[i].name, autoCS.texSys.outTextures[i].tex);
        }
        //??? DynamicValSys
        for (int i = 0; i < autoCS.dyValSys.outFloats.Count; i++)
        {
            //var tName = autoCS.dyValSys.outFloats[i].name;
            //var tF = autoCS.dyValSys.outFloats[i].GetVal();
            cs.SetFloat(autoCS.dyValSys.outFloats[i].name, autoCS.dyValSys.outFloats[i].GetVal());
            //Debug.Log("Dynamic: " + tName + " " + tF);
        }
        //___
        //####

        cs.SetTexture(kInx, "Result", rt);
        cs.SetTexture(kInx, "envSpecTex2DArr", envSpecTex2DArr);
        cs.SetTexture(kInx, "envBgTex", envBgTex);

        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetFloat("pixW", pixW);
        cs.SetFloat("pixH", pixH);
        cs.SetVector("screenLeftDownPix", screenLeftDownPix);
        cs.SetVector("eyePos", eyePos);
        cs.SetVector("screenU", screenU);
        cs.SetVector("screenV", screenV);

        cs.Dispatch(kInx, w / CoreX, h / CoreY, 1);
        //### compute
        //#####################################;
    }
    //####################################################################################

    void Init()
    {
        if (rt == null)
        {
            rt = new RenderTexture(w, h, 24);
            rt.enableRandomWrite = true;
            rt.Create();
            //???
            CreateRT(ref easuRT, FSR_Scale);
            CreateRT(ref finalRT, FSR_Scale);
            var csResourcesPath = ChopEnd(autoCS.outs[0], ".compute");
            csResourcesPath = ChopBegin(csResourcesPath, "Resources/");
            cs = (ComputeShader)Resources.Load(csResourcesPath);
            cs_FSR = (ComputeShader)Resources.Load("FSR/FSR");
        }
        hasInited = true;
    }

    public void RefreshAutoCS()
    {
        autoCS.Generate();
    }

    void DoRender()
    {
        Compute_Render();
    }

    void CreateRT(ref RenderTexture rTex, float scale=1.0f)
    {
        rTex = new RenderTexture((int)(w* scale), (int)(h* scale), 24);
        rTex.enableRandomWrite = true;
        rTex.Create();
    }
    //####################################################################################

    static public void SafeDispose(ComputeBuffer cb)
    {
        if (cb != null)
        {
            cb.Dispose();
        }
    }

    //static public void Tex2RT(ref RenderTexture rt, Texture2D tex, bool enableRW=true)
    //{ 
    //    rt = new RenderTexture(tex.width, tex.height, 24);
    //    if (enableRW)
    //    {
    //        rt.enableRandomWrite = true;
    //    }
    //    var ori = RenderTexture.active;
    //
    //    RenderTexture.active = rt;
    //
    //    Graphics.Blit(tex, rt);
    //    rt.Create();
    //
    //    RenderTexture.active = ori;
    //}

    public float GetDaoScale()
    {
        return daoScale;
    }
    //####################################################################################
    IEnumerator Co_GoIter;
    //@@@
    private void OnGUI()
    {

        GUI.Label(new Rect(0, 50, 300, 50), "FPS: " + fps);

        if (GUI.Button(new Rect(0, 0, 100, 50), "GoRender!"))
        {
            Co_GoIter = GoIter();
            StartCoroutine(Co_GoIter);
        }
    }

    IEnumerator GoIter()
    {
        while(true)
        {
            fpsTimer.Start();
            Init();
            UpdateCamParam();
            DoRender();
            yield return null;
            fps = fpsTimer.GetFPS();
        }
    }
}
