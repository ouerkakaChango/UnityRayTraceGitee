using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static DebugUtility.DebuggerFuns;

public class ResolutionDebugger : MonoBehaviour
{
    public RenderResolution renderReso = null;
    public bool runtimeToggle = true;
    public List<Vector2Int> toggleList;
    int toggleInx = 0;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnGUI()
    {
        Vector2Int screenSize = GetRenderSize(gameObject);

        RenderTexture.active = null;
        if (renderReso && runtimeToggle && toggleList.Count > 0)
        {
            if (GUI.Button(new Rect(screenSize.x * 0.3f, screenSize.y * 0.1f * 1, screenSize.x * 0.1f, screenSize.y * 0.1f), "toggleRenderResolution"))
            {
                renderReso.ChangeSize(toggleList[toggleInx]);
                toggleInx++;
                if (toggleInx == toggleList.Count)
                {
                    toggleInx = 0;
                }
            }
        }
        //RenderTexture.active = ori;
    }
}
