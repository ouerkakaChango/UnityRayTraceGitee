using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum PntsVisualRangeType
{
    None,
    Color,
};

public struct ColorRangeInfo
{
    public Color color;
    public int start, end;
    public float scale;
}

public class PntsVisualizer : MonoBehaviour
{
    public bool always = false;
    public float pntScale = 1.0f;
    public List<Vector3> pnts = new List<Vector3>();
    List<ColorRangeInfo> colorRanges = new List<ColorRangeInfo>();
    public PntsVisualRangeType rangeType = PntsVisualRangeType.None;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    void OnDrawGizmosSelected()
    {
        if(!always)
        {
            Draw();
        }
    }

    private void OnDrawGizmos()
    {
        if (always)
        {
            Draw();
        }
    }

    //##############################################################

    void Draw()
    {
        if (rangeType == PntsVisualRangeType.None)
        {
            Gizmos.color = Color.red;
            for (int i = 0; i < pnts.Count; i++)
            {
                Gizmos.DrawCube(pnts[i], pntScale * 0.01f * Vector3.one);
            }
        }
        else if (rangeType == PntsVisualRangeType.Color)
        {
            foreach (var info in colorRanges)
            {
                Gizmos.color = info.color;
                //Debug.Log(info.start + " " + info.end);
                for (int i = info.start; i < info.end; i++)
                {
                    Gizmos.DrawCube(pnts[i], info.scale * 0.01f * Vector3.one);
                }
            }
        }
    }

    public void Clear()
    {
        pnts.Clear();
        colorRanges.Clear();
    }

    public void Add(Vector3 p)
    {
        pnts.Add(p);
        if (rangeType == PntsVisualRangeType.Color)
        {
            var info = colorRanges[colorRanges.Count - 1];
            info.end += 1;
            colorRanges[colorRanges.Count - 1] = info;
        }
    }

    public void BeginRange(Color color, float scale=1.0f)
    {
        if (rangeType != PntsVisualRangeType.Color)
        {
            Clear();
            rangeType = PntsVisualRangeType.Color;
        }
        if (colorRanges.Count == 0 || color != colorRanges[colorRanges.Count - 1].color)
        {
            ColorRangeInfo info;
            info.color = color;
            info.start = pnts.Count;
            info.end = info.start;
            info.scale = scale;
            colorRanges.Add(info);
        }
    }
}
