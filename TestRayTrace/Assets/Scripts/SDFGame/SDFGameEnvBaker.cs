using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using TextureHelper;

public class SDFGameEnvBaker : MonoBehaviour
{
    public string outName = "envtex";
    public SDFGameSceneTrace tracer;
    public Vector2Int shotSize;
    SDFGameCameraParam shotParam;

    public Texture2D[] cubeOut = new Texture2D[6];
    public Vector2Int outEnvSize = new Vector2Int(1024,512);
    public Texture2D outEnvTex;
    public Texture2D[] outIBLArr = null;
    public Texture2DArray outEnvTexArr = null;

    // Start is called before the first frame update
    void Start()
    {
        shotParam = new SDFGameCameraParam();
        shotParam.w = shotSize.x;
        shotParam.h = shotSize.y;
        var keyboard = tracer.gameObject.GetComponent<KeyboardInputer>();
        keyboard.keyDic.Add("2", OutputIBLTexArr_CubeMapMode);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //############################################
    public void OutputCubemap()
    {
        var oriParam = new SDFGameCameraParam(shotParam);
        //因为是cubemap，用了网上的转换工具，要求w ==h
        shotParam.h = shotParam.w;
        shotParam.camType = 2;
        shotParam.camGammaMode = 1;

        RenderTexture rt = null;
        var tcam = gameObject.AddComponent<Camera>();

        //前
        gameObject.transform.rotation = Quaternion.Euler(0, 0, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[0], ref rt);

        //上
        gameObject.transform.rotation = Quaternion.Euler(-90, 0, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[1], ref rt);

        //下
        gameObject.transform.rotation = Quaternion.Euler(90, 0, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[2], ref rt);

        //后(negz)
        gameObject.transform.rotation = Quaternion.Euler(180, 0, 180);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[3], ref rt);

        //左
        gameObject.transform.rotation = Quaternion.Euler(0, -90, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[4], ref rt);

        //右
        gameObject.transform.rotation = Quaternion.Euler(0, 90, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[5], ref rt);

        Destroy(tcam);
        shotParam = oriParam;
    }

    public void OutputEnvTex_CubeMapMode()
    {
        OutputCubemap();
        //cube to Equirectangular
        outEnvTex = null;
        EnvTexFromCubeMap(ref outEnvTex, outEnvSize.x, outEnvSize.y, ref cubeOut);
    }

    public static void EnvTexFromCubeMap(ref Texture2D envTex, int w, int h, ref Texture2D[] cubes)
    {
        if(cubes.Length!=6)
        {
            Debug.LogError("Cubes size not 6");
            return;
        }

        RenderTexture rt = null;
        TexHelper.CreateRT(ref rt, w, h);
        var cs = Resources.Load<ComputeShader>("ConvertCS/CubesToEnvTex");
        //##################################
        //### compute
        int kInx = cs.FindKernel("CSMain");

        cs.SetTexture(kInx, "Result", rt);
        cs.SetTexture(kInx, "front", cubes[0]);
        cs.SetTexture(kInx, "up", cubes[1]);
        cs.SetTexture(kInx, "down", cubes[2]);
        cs.SetTexture(kInx, "back", cubes[3]);
        cs.SetTexture(kInx, "left", cubes[4]);
        cs.SetTexture(kInx, "right", cubes[5]);

        cs.Dispatch(kInx, w / 8, h / 8, 1);
        //### compute
        //#####################################
        TexHelper.RT2Tex2D(ref envTex, ref rt);
    }

    public void OutputIBLArr_CubeMapMode()
    {
        OutputEnvTex_CubeMapMode();
        var iblBaker = gameObject.AddComponent<IBLSpecBaker>();
        iblBaker.envRefTex = outEnvTex;
        iblBaker.UseDefaultBakeCS();
        iblBaker.Bake_AverageDelta(ref outIBLArr);
        Destroy(iblBaker);
    }

    public void OutputIBLTexArr_CubeMapMode()
    {
        OutputIBLArr_CubeMapMode();
        var generator = gameObject.AddComponent<Tex2DArrGenerator>();
        generator.texs = outIBLArr;
        generator.CreateTexArray();
        outEnvTexArr = generator.outTex2DArr;
        Destroy(generator);
    }

}
