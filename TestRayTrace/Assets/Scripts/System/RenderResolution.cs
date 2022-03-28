using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class RenderResolution : MonoBehaviour
{
    public Camera mainCam;
    public Vector2Int renderSize = new Vector2Int(640, 360);
    RenderTexture rt;
    CommandBuffer cmd;
    void Start()
    {
        rt = new RenderTexture(renderSize.x, renderSize.y, 24);
        mainCam.SetTargetBuffers(rt.colorBuffer, rt.depthBuffer);

        cmd = new CommandBuffer();
        //cmd.Clear();
        cmd.Blit(rt, (RenderTexture)null);
        mainCam.AddCommandBuffer(CameraEvent.AfterEverything, cmd);
    }

    // Update is called once per frame
    void Update()
    {

    }
    //#############################################################
    public void ChangeSize(Vector2Int size)
    {
        if (size.x > 0 && size.y > 0)
        {
            renderSize = size;
            mainCam.RemoveCommandBuffer(CameraEvent.AfterEverything, cmd);

            rt = new RenderTexture(renderSize.x, renderSize.y, 24);
            mainCam.SetTargetBuffers(rt.colorBuffer, rt.depthBuffer);

            cmd = new CommandBuffer();
            //cmd.Clear();
            cmd.Blit(rt, (RenderTexture)null);
            mainCam.AddCommandBuffer(CameraEvent.AfterEverything, cmd);
        }
    }
}
