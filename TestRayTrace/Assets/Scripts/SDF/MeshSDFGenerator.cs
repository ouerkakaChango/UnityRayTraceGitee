using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PointCloudHelper;
using Debugger;
using MathHelper;

public class MeshSDFGenerator : MonoBehaviour
{
    public bool needFixScale100 = true;
    Vector3[] vertices;

    public MeshSDFExtendType extendType = MeshSDFExtendType.Ground;
    public Vector3Int unitDivide = new Vector3Int(10,10,10);
    public Vector3Int unitExtend = new Vector3Int(2,2,2);
    Vector3 unit;
    Vector3 startUnitPos;   //modelϵ
    Bounds meshBounds;
    Vector3Int unitCount;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Generate()
    {
        var mf = GetComponent<MeshFilter>();
        var mesh = mf.sharedMesh;
        vertices = mesh.vertices;

        if (needFixScale100)
        {
            FixScale100();
        }

        meshBounds = PCL.GetBounds(vertices);
        Debug.Log(meshBounds);

        unit = Vec.Divide(meshBounds.extents * 2, unitDivide);
        InitStartUnitPos();
        InitUnitCount();
    }

    void FixScale100()
    {
        for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i] *= 100.0f; 
        }
    }

    void InitStartUnitPos()
    {
        if (extendType == MeshSDFExtendType.Ground)
        {
            startUnitPos = meshBounds.min + 0.5f * unit;
            var t1 = unitExtend;
            t1.y = 0;
            startUnitPos -= Vec.Mul(unit, t1);
        }
    }

    void InitUnitCount()
    {
        if (extendType == MeshSDFExtendType.Ground)
        {
            unitCount = unitDivide + Vec.MulInt(unitExtend,new Vector3(2,1,2));
        }
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(0, 1, 0, 0.2f);
        Gizmos.DrawCube(transform.position+meshBounds.center, meshBounds.extents*2);

        Gizmos.color = new Color(1, 0, 0, 0.5f);
        Gizmos.DrawSphere(transform.position + startUnitPos, 0.05f);
        Gizmos.color = new Color(0, 0, 0, 0.5f);

        var lineCount = unitCount + new Vector3Int(1, 1, 1);
        var start = startUnitPos - unit * 0.5f;
        //x align 
        for (int k = 0; k < lineCount.z; k++)
        {
            for (int j = 0; j < lineCount.y; j++)
            {
                Vector3 p = start + Vec.Mul(unit,new Vector3(0, j, k));
                var p1 = p;
                p1 += transform.position;
                var p2 = new Vector3(start.x + unitCount.x * unit.x, p.y, p.z);
                p2 += transform.position;
                Gizmos.DrawLine(p1, p2);
            }
        }

        //y align
        for (int k = 0; k < lineCount.z; k++)
        {
            for (int i = 0; i < lineCount.x; i++)
            {
                Vector3 p = start + Vec.Mul(unit, new Vector3(i, 0, k));
                var p1 = p;
                p1 += transform.position;
                var p2 = new Vector3(p.x, start.y + unitCount.y * unit.y, p.z);
                p2 += transform.position;
                Gizmos.DrawLine(p1, p2);
            }
        }

        //z align
        for (int j = 0; j < lineCount.y; j++)
        {
            for (int i = 0; i < lineCount.x; i++)
            {
                Vector3 p = start + Vec.Mul(unit, new Vector3(i, j, 0));
                var p1 = p;
                p1 += transform.position;
                var p2 = new Vector3(p.x, p.y, start.z + unitCount.z * unit.z);
                p2 += transform.position;
                Gizmos.DrawLine(p1, p2);
            }
        }
    }
}
