using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SDFGameEnvBaker : MonoBehaviour
{
    public RenderTexture testrt;
    public SDFGameSceneTrace tracer;
    public Camera testCam;
    SDFGameCameraParam testParam;

    // Start is called before the first frame update
    void Start()
    {
        testCam = gameObject.GetComponent<Camera>();
        testParam = new SDFGameCameraParam();
        testParam.w = 1920;
        testParam.h = 1080;
        var keyboard = tracer.gameObject.GetComponent<KeyboardInputer>();
        keyboard.keyDic.Add("2", TestShot);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //############################################
    public void TestShot()
    {
        tracer.RenderCamToRT(ref testrt, ref testCam, testParam);
    }

}
