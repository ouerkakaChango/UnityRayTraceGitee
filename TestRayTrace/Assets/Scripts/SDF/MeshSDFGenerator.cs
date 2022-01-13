using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PointCloudHelper;
using Debugger;
using MathHelper;
using static MathHelper.Vec;
using FastGeo;
using Ray = FastGeo.Ray;

public enum MeshSDFGenerateSampleType
{
    unitSphere, //unform distribute 
    testCenter, //always center
};

public class MeshSDFGenerator : MonoBehaviour
{
    bool hasInited = false;

    public bool showMeshBound = true;
    public bool showGrid = true;
    public bool showSDF = true;
    public bool needFixScale100 = true;
    Vector3[] vertices;

    public MeshSDFExtendType extendType = MeshSDFExtendType.Ground;
    public Vector3Int unitDivide = new Vector3Int(10,10,10);
    public Vector3Int unitExtend = new Vector3Int(2,2,2);
    Vector3 unit;
    Vector3 startUnitPos;   //model coordinate
    Bounds meshBounds;
    Vector3Int unitCount;

    MeshSDFGenerateSampleType sampleType = MeshSDFGenerateSampleType.unitSphere;
    float[] sdfArr;
    float[] debugColor;
    //###########################################
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
        if (!hasInited)
        {
            return;
        }

        if (showMeshBound)
        {
            Gizmos.color = new Color(0, 1, 0, 0.2f);
            Gizmos.DrawCube(transform.position + meshBounds.center, meshBounds.extents * 2);
        }

        if (showGrid)
        {
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
                    Vector3 p = start + Vec.Mul(unit, new Vector3(0, j, k));
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

        if (showSDF && debugColor != null)
        {
            int cc = 0;
            Gizmos.color = Color.red;
            for (int k = 0; k < unitCount.z; k++)
            {
                for (int j = 0; j < unitCount.y; j++)
                {
                    for (int i = 0; i < unitCount.x; i++)
                    {
                        float c = debugColor[i + j * unitCount.x + k * unitCount.x * unitCount.y];
                        Gizmos.color = new Color(0, 0,0,c);
                        Gizmos.DrawSphere(ToWorld(startUnitPos + Mul(unit,new Vector3(i,j,k))), 0.05f);
                        cc++;
                        //if (cc > 5000)
                        //{
                        //    return;
                        //}
                    }
                }
            }
                        
        }
    }

    //#######################################################################

    public void InitGrid()
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

        hasInited = true;
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
            unitCount = unitDivide + Vec.MulToInt3(unitExtend,new Vector3(2,1,2));
        }
    }

    Vector3 ToWorld(in Vector3 posInModelCoord)
    {
        return posInModelCoord + transform.position;
    }

    public void TestTrace()
    {
        if (!hasInited)
        {
            Debug.Log("TestTrace need grid has inited");
            return;
        }
        Debug.Log("TestTrace");
        var visual = GetComponent<RayHitVisualizer>();

        Vector3 pos = ToWorld(startUnitPos);
        Vector3 dir = (meshBounds.center - startUnitPos).normalized; //旋转不需要model转world，都一样
        Ray ray = new Ray(pos, dir);

        //visual.rays.Add(new Line(pos, pos + dir * 2));

        var bvhComp = GetComponent<BVHTool>();
        if (!bvhComp.IsInited())
        {
            Debug.Log("TestTrace need bvh has inited");
            return;
        }
        var hitInfo = bvhComp.Trace(ray);
        visual.Add(ray,hitInfo);
    }

    const int maxSampleCount = 30;

    int GetSampleCount()
    {
        if (sampleType == MeshSDFGenerateSampleType.testCenter)
        {
            return 1;
        }
        else
        {
            return maxSampleCount;
        }
    }

    Vector3 GetSampleDir(in Vector3 pos, int sampleInx)
    {
        return (ToWorld(meshBounds.center) - pos).normalized;
    }

    public void Bake()
    {
        TimeLogger logger = new TimeLogger("Bake Mesh SDF");
        logger.Start();
        var visual = GetComponent<RayHitVisualizer>();

        var bvhComp = GetComponent<BVHTool>();
        if (!bvhComp.IsInited())
        {
            Debug.Log("Bake need bvh has inited");
            return;
        }

        sdfArr = new float[unitCount.x * unitCount.y * unitCount.z];

        for (int k = 0; k < unitCount.z; k++)
        {
            for (int j = 0; j < unitCount.y; j++)
            {
                for (int i = 0; i < unitCount.x; i++)
                {
                    Vector3 pos = ToWorld(startUnitPos + Mul(unit,new Vector3(i,j,k)));
                    {
                        //Vector3 dir = (ToWorld(meshBounds.center) - pos).normalized;
                        //Ray ray = new Ray(pos, dir);
                        //var hitInfo = bvhComp.Trace(ray);
                        //visual.Add(ray, hitInfo);
                    }
                    bool validSDF = false;
                    float minDis = 1000000.0f;
                    int sampleNum = GetSampleCount();
                    for (int testInx = 0; testInx < sampleNum; testInx++)
                    {
                        Vector3 dir = GetSampleDir(pos, testInx);
                        Ray ray = new Ray(pos, dir);
                        HitInfo hitInfo = bvhComp.Trace(ray);
                        if (hitInfo.bHit)
                        {
                            float tDis = length(hitInfo.P - pos);
                            if (tDis < minDis)
                            {
                                minDis = tDis;
                                validSDF = true;
                            }
                        }
                    }
                    //Save minDis to sdfArr
                    sdfArr[i + j * unitCount.x + k * unitCount.x * unitCount.y] = minDis;
                }
            }
        }

        float maxDis = maxComp(unitCount) * maxComp(unit);

        debugColor = new float[sdfArr.Length];
        for (int i = 0; i < sdfArr.Length; i++)
        {
            float d = sdfArr[i] < maxDis ? sdfArr[i] : maxDis;
            debugColor[i] = pow(saturate(1 - d / maxDis),5);
        }
        logger.LogSec();
    }
}
