using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DebugUtility
{
    public static class DebuggerFuns
    {
        public static Vector2Int GetRenderSize(GameObject obj)
        {
            Vector2Int re = new Vector2Int(0,0);
            var renderReso = obj.GetComponent<RenderResolution>();
            if (renderReso)
            {
                re = renderReso.renderSize;
            }
            else
            {
                re = new Vector2Int(Screen.width, Screen.height);
            }
            return re;
        }
    }
}
