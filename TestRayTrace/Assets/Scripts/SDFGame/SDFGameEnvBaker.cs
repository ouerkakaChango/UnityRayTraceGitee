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
        //��Ϊ��cubemap���������ϵ�ת�����ߣ�Ҫ��w ==h
        shotParam.h = shotParam.w;
        shotParam.camType = 2;
        shotParam.camGammaMode = 1;

        RenderTexture rt = null;
        var tcam = gameObject.AddComponent<Camera>();

        //ǰ
        gameObject.transform.rotation = Quaternion.Euler(0, 0, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[0], ref rt);

        //��
        gameObject.transform.rotation = Quaternion.Euler(-90, 0, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[1], ref rt);

        //��
        gameObject.transform.rotation = Quaternion.Euler(90, 0, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[2], ref rt);

        //��(negz)
        gameObject.transform.rotation = Quaternion.Euler(180, 0, 180);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[3], ref rt);

        //��
        gameObject.transform.rotation = Quaternion.Euler(0, -90, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[4], ref rt);

        //��
        gameObject.transform.rotation = Quaternion.Euler(0, 90, 0);
        tracer.RenderCamToRT(ref rt, ref tcam, shotParam);
        TexHelper.RT2Tex2D(ref cubeOut[5], ref rt);

        Destroy(tcam);
        shotParam = oriParam;
    }

}
