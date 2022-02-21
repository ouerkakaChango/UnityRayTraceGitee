using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

//每帧将renderRT通过FSR缩放算法画到更大的finalRT上去
public class FSRPostProcessor : MonoBehaviour
{
    public Camera cam;
    public RawImage rawImage;

    RenderTexture renderRT;
    RenderTexture easuRT;
    RenderTexture finalRT;

    ComputeShader cs;

    public Vector2Int renderSize = new Vector2Int(512,360);
    public Vector2Int finalSize = new Vector2Int(1024, 720);

    int mode = 0;

    // Start is called before the first frame update
    void Start()
    {
        CreateRT(ref renderRT, renderSize, 24);
        CreateRT(ref easuRT, finalSize);
        CreateRT(ref finalRT, finalSize);
        cam.targetTexture = renderRT;
        rawImage.texture = finalRT;
    }

    // Update is called once per frame
    void Update()
    {
        if (mode == 0)
        {
            //SimpleCopy
            Compute_SimpleCopy();
        }
        else if (mode == 1)
        {
            cs = (ComputeShader)Resources.Load("FSR/FSR");

            int kInx = cs.FindKernel("EASU");
            cs.SetTexture(kInx, "inTex", renderRT);
            cs.SetTexture(kInx, "Result", easuRT);
            cs.Dispatch(kInx, finalSize.x / 8, finalSize.y / 8, 1);

            kInx = cs.FindKernel("RCAS");
            cs.SetTexture(kInx, "easuRT", easuRT);
            cs.SetTexture(kInx, "Result", finalRT);
            cs.Dispatch(kInx, finalSize.x / 8, finalSize.y / 8, 1);
        }
    }

    private void OnGUI()
    {
        if (GUI.Button(new Rect(20, 70, 400, 400), "ToggleFSR(now "+ mode +")"))
        {
            mode++;
            if (mode == 2)
            {
                mode = 0;
            }
        }
    }

    //#####################################################

    public static void CreateRT(ref RenderTexture rTex, Vector2Int size, int depth = 0)
    {
        rTex = new RenderTexture(size.x, size.y, depth, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        rTex.enableRandomWrite = true;
        rTex.Create();
    }

    void Compute_SimpleCopy()
    {
        cs = (ComputeShader)Resources.Load("CommonFiliterCS/Scale");

        int kInx = cs.FindKernel("CSMain");
        cs.SetTexture(kInx, "inTex", renderRT);
        cs.SetTexture(kInx, "Result", finalRT);
        cs.Dispatch(kInx, finalSize.x / 8, finalSize.y / 8, 1);
    }
}
