using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MathHelper;
using FastGeo;

[ExecuteInEditMode]
public class TestCellInx : MonoBehaviour
{
    public bool hasInit = false;
    public Vector3[] pos;
    public string[] text;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(!hasInit)
        {
            Init();
        }
    }

    //≤‚ ‘
    //int3 GetCellInx(in float3 pntPos, in float3 startPos, in float3 unit, in float3 subDivide)
    //pntPos -3.5,-3.5 
    //startPos -4 -4
    //unit 1 1 1
    //subDivide 8,8,8

    void Init()
    {
        Vector3 unit = Vector3.one;
        Vector3 start = -3.5f * Vector3.one;
        Vector3Int unitCount = new Vector3Int(8, 8, 8);

        int len = unitCount.x * unitCount.y * unitCount.z;
        pos = new Vector3[len];
        text = new string[len];
        for (int k=0;k< unitCount.z; k++)
        {
            for (int j = 0; j < unitCount.y; j++)
            {
                for (int i = 0; i < unitCount.x; i++)
                {
                    var p = start + Vec.Mul(unit, new Vector3(i, j, k));
                    int inx = i + j * (unitCount.x) + k * (unitCount.x * unitCount.y);
                    pos[inx] = p;
                    Vector3Int cellInx = GridMath.GetCellInx(p, start - 0.5f * unit, unit, unitCount);
                    text[inx] = cellInx.ToString();
                }
            }
        }

        var visual = GetComponent<TextVisualizer>();
        //visual.pnts = pos;
        //visual.text = text;
        visual.Clear();
        for (int i = 0; i < pos.Length; i++)
        {
            visual.Add(pos[i], text[i]);
        }
        hasInit = true;
    }

}
