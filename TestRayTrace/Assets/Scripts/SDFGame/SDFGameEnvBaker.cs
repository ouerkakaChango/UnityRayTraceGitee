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

    // Start is called before the first frame update
    void Start()
    {
        shotParam = new SDFGameCameraParam();
        shotParam.w = shotSize.x;
        shotParam.h = shotSize.y;
        var keyboard = tracer.gameObject.GetComponent<KeyboardInputer>();
        keyboard.keyDic.Add("2", OutputCubemap);
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

}
