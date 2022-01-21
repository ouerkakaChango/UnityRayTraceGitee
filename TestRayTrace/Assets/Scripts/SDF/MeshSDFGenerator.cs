using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using PointCloudHelper;
using Debugger;
using MathHelper;
using static MathHelper.Vec;
using static MathHelper.XMathFunc;
using FastGeo;
using Ray = FastGeo.Ray;
using XFileHelper;
using XUtility;
using static ComputeShaderHelper;

public enum MeshSDFGenerateSampleType
{
    lowDiscrepancy, //低差异序列
    unitSphere, //unform distribute 
    testCenter, //always center
};

public class MeshSDFGenerator : MonoBehaviour
{
    bool hasInited = false;

    public int maxSampleCount = 160;

    public bool showMeshBound = true;
    public bool showGrid = true;
    public bool showSDF = true;
    public bool needFixScale100 = true;

    public MeshSDFExtendType extendType = MeshSDFExtendType.Default;
    public Vector3Int unitDivide = new Vector3Int(60,60,60);
    public Vector3Int unitExtend = new Vector3Int(16,16,16);
    [ReadOnly]
    public Vector3 unit;
    [ReadOnly]
    public Vector3 startUnitPos;   //model coordinate
    [SerializeField]
    Bounds meshBounds;
    [ReadOnly]
    public Vector3Int unitCount;

    public MeshSDFGenerateSampleType sampleType = MeshSDFGenerateSampleType.unitSphere;
    [HideInInspector]
    public float[] sdfArr;
    float[] debugColor;
    public string outPath = "Assets/meshSDF.bytes";
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
        //Debug.Log(debugColor);
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
                        Gizmos.color = new Color(0, 0,0, c);
                        Gizmos.DrawSphere(ToWorld(startUnitPos + Mul(unit,new Vector3(i,j,k))), unit.magnitude/4.0f);
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
        var vertices = mesh.vertices;

        if (needFixScale100)
        {
            FixScale100(ref vertices);
        }

        meshBounds = PCL.GetBounds(vertices);
        Debug.Log(meshBounds);

        unit = Vec.Divide(meshBounds.extents * 2, unitDivide);
        InitStartUnitPos();
        InitUnitCount();

        hasInited = true;
        debugColor = null;
    }

    void FixScale100(ref Vector3[] vertices)
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
        else if (extendType == MeshSDFExtendType.Default)
        {
            startUnitPos = meshBounds.min + 0.5f * unit;
            startUnitPos -= Vec.Mul(unit, unitExtend);
        }
    }

    void InitUnitCount()
    {
        if (extendType == MeshSDFExtendType.Ground)
        {
            unitCount = unitDivide + Vec.MulToInt3(unitExtend,new Vector3(2,1,2));
        }
        else if (extendType == MeshSDFExtendType.Default)
        {
            unitCount = unitDivide + Vec.MulToInt3(unitExtend, new Vector3(2, 2, 2));
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

        Vector3 pos = ToWorld(startUnitPos + Vec.Mul(unit, new Vector3Int(0, 0, 0)));
        //Vector3 pos = startUnitPos;
        Vector3 dir = (meshBounds.center - startUnitPos).normalized; //旋转不需要model转world，都一样
        Ray ray = new Ray(pos, dir);

        var bvhComp = GetComponent<BVHTool>();
        if (!bvhComp.IsInited())
        {
            Debug.Log("TestTrace need bvh has inited");
            return;
        }
        bvhComp.UpdateMeshInfos();

        //Debug.Log("FF");
        //Debug.Log(startUnitPos+Vec.Mul(unit,new Vector3Int(0,1,0)));
        //Debug.Log(pos);
        //var hitInfo = bvhComp.TraceWorldRay(ray);

        //ray.pos -= transform.position;
        //var hitInfo = bvhComp.TraceLocalRay(ray);

        //??? -0.8和-0.800002结果不同，可能正好穿过三角形顶点，漏了
        //var hitInfo = bvhComp.TraceLocalRay(new Ray(new Vector3(-0.8002f, startUnitPos.y, startUnitPos.z), ray.dir));
        TimeLogger logger = new TimeLogger("TraceWorldRay");
        logger.Start();
        var hitInfo = bvhComp.TraceWorldRay(ray);
        logger.Log();
        visual.Add(ray,hitInfo);
    }

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

    public Vector3 GetSampleDir(in Vector3 pos, int sampleInx, Vector3 seed)
    {
        if (sampleType == MeshSDFGenerateSampleType.testCenter)
        {
            return (ToWorld(meshBounds.center) - pos).normalized;
        }
        else if (sampleType == MeshSDFGenerateSampleType.unitSphere)
        {
            if (sampleInx == 0)
            {
                return (ToWorld(meshBounds.center) - pos).normalized;
            }
            else
            {
                return CPURand.random_on_unit_sphere();
            }
        }
        else if (sampleType == MeshSDFGenerateSampleType.lowDiscrepancy)
        {
            if (sampleInx == 0)
            {
                return (ToWorld(meshBounds.center) - pos).normalized;
            }
            else
            {
                return LDRand.randP_round(seed);
            }
        }
        else
        {
            return CPURand.random_on_unit_sphere();
        }
    }

    public void Bake()
    {
        TimeLogger logger = new TimeLogger("Bake Mesh SDF");
        logger.Start();
        var visual = GetComponent<RayHitVisualizer>();
        if (!visual)
        {
            Debug.Log("Bake need RayHitVisualizer");
            return;
        }

        var bvhComp = GetComponent<BVHTool>();
        if (!bvhComp.IsInited())
        {
            Debug.Log("Bake need bvh has inited");
            return;
        }
        bvhComp.UpdateMeshInfos();

        sdfArr = new float[unitCount.x * unitCount.y * unitCount.z];

        for (int k = 0; k < unitCount.z; k++)
        {
            for (int j = 0; j < unitCount.y; j++)
            {
                for (int i = 0; i < unitCount.x; i++)
                {
                    Vector3 pos = ToWorld(startUnitPos + Mul(unit,new Vector3(i,j,k)));
                    float minDis = 1000000.0f;
                    bool bValid = false;
                    int sampleNum = GetSampleCount();
                    for (int testInx = 0; testInx < sampleNum; testInx++)
                    {
                        Vector3 dir = GetSampleDir(pos, testInx, new Vector3(i, j,k + testInx));
                        Ray ray = new Ray(pos, dir);
                        HitInfo hitInfo = bvhComp.TraceWorldRay(ray);
                        if (hitInfo.bHit)
                        {
                            float tDis = length(hitInfo.P - pos);
                            if (tDis < minDis)
                            {
                                minDis = tDis;
                                bValid = true;
                            }
                            //visual.hitPnts.Add(hitInfo.P);
                            //visual.hitPnts.Add(ray.pos);
                        }
                        //???
                        if (i == 0 && j == 0 && k == 0)
                        {
                            visual.Add(ray, hitInfo);
                        }
                    }
                    if (!bValid)
                    {
                        minDis = 0;
                        //visual.missLines.Add(new Line(Vector3.zero, new Vector3(0, 2, 0)));
                    }
                    //Save minDis to sdfArr
                    sdfArr[i + j * unitCount.x + k * unitCount.x * unitCount.y] = minDis;
                }
            }
        }

        UpdateDebugSDFColor();
        logger.LogSec();
    }

    public void BakeGPU()
    {
        TimeLogger logger = new TimeLogger("GPU Bake Mesh SDF");
        logger.Start();
        var bvhComp = GetComponent<BVHTool>();
        if (!bvhComp.IsInited())
        {
            Debug.Log("Bake need bvh has inited");
            return;
        }
        bvhComp.UpdateMeshInfos();

        //bvh = bvhComp.tree;
        //tris = bvhComp.tris;
        //vertices = mesh.vertices;
        //normals = mesh.normals;

        Compute_Bake(ref bvhComp);

        UpdateDebugSDFColor();
        logger.LogSec();
    }

    void Compute_Bake(ref BVHTool bvhComp)
    {
        //var mf = GetComponent<MeshFilter>();
        //var mesh = mf.sharedMesh;

        int len = unitCount.x * unitCount.y * unitCount.z;
        sdfArr = new float[len];

        ComputeBuffer buffer_vertices = null;
        ComputeBuffer buffer_normals = null;
        ComputeBuffer buffer_tris = null;
        ComputeBuffer buffer_bvh = null;
        ComputeBuffer buffer_sdfArr = null;

        PreComputeBuffer(ref buffer_vertices, sizeof(float) * 3, bvhComp.vertices);
        PreComputeBuffer(ref buffer_normals, sizeof(float) * 3, bvhComp.normals);
        PreComputeBuffer(ref buffer_tris, sizeof(int), bvhComp.tris);
        PreComputeBuffer(ref buffer_bvh, BVHNode.GetBVHStride(), bvhComp.tree);
        PreComputeBuffer(ref buffer_sdfArr, sizeof(float), sdfArr);

        var cs = (ComputeShader)Resources.Load("BakeCS/BakeMeshSDF");
        //##################################
        //### compute
        int kInx = cs.FindKernel("BakeSDF");

        cs.SetBuffer(kInx, "tris", buffer_tris);
        cs.SetBuffer(kInx, "vertices", buffer_vertices);
        cs.SetBuffer(kInx, "normals", buffer_normals);
        cs.SetBuffer(kInx, "bvh", buffer_bvh);
        cs.SetBuffer(kInx, "sdfArr", buffer_sdfArr);

        cs.SetVector("startPos", startUnitPos);
        cs.SetVector("unitCount", (Vector3)unitCount);
        cs.SetVector("unit", unit);

        cs.SetInt("treeDepth", bvhComp.depth);
        cs.SetInt("sampleCount", GetSampleCount());

        //!!! cs core(1,1,1)
        cs.Dispatch(kInx, unitCount.x/4, unitCount.y/4, unitCount.z/4);
        //### compute
        //#####################################;
        buffer_sdfArr.GetData(sdfArr);

        SafeDispose(buffer_tris);
        SafeDispose(buffer_vertices);
        SafeDispose(buffer_normals);
        SafeDispose(buffer_bvh);
        SafeDispose(buffer_sdfArr);
    }

    void UpdateDebugSDFColor()
    {
        float maxDis = meshBounds.extents.magnitude*2.0f;
        Debug.Log(maxDis);
        debugColor = new float[sdfArr.Length];
        for (int i = 0; i < sdfArr.Length; i++)
        {
            //Debug.Log(sdfArr[i]);
            float d = sdfArr[i] < maxDis ? sdfArr[i] : maxDis;
            debugColor[i] = pow(saturate(1 - d / maxDis), 5);
        }
    } 

    public void TestSaveStandardSphere()
    {
        //0.5半径的正圆，5 divide, 1 extend
        meshBounds.min = Vector3.one * (-0.5f);
        meshBounds.max = Vector3.one * (0.5f);
        unitDivide = new Vector3Int(10, 10, 10);
        unitExtend = new Vector3Int(2, 2, 2);
        InitUnitCount();
        unit = Vec.Divide(meshBounds.extents * 2, unitDivide);
        startUnitPos = meshBounds.min + 0.5f * unit;
        var t1 = unitExtend;
        t1.y = 0;
        startUnitPos -= Vec.Mul(unit, t1);

        float radius = 0.5f;
        sdfArr = new float[unitCount.x * unitCount.y * unitCount.z];
        string tt = "";
        for (int k = 0; k < unitCount.z; k++)
        {
            for (int j = 0; j < unitCount.y; j++)
            {
                for (int i = 0; i < unitCount.x; i++)
                {
                    var p = startUnitPos + Mul(unit, new Vector3(i, j, k));
                    //if(p.magnitude<= radius)
                    //{
                    //    sdfArr[i + j * unitCount.x + k * unitCount.x * unitCount.y] = 0;
                    //}
                    //else
                    {
                        sdfArr[i + j * unitCount.x + k * unitCount.x * unitCount.y] = p.magnitude - radius;
                    }
                    tt += sdfArr[i + j * unitCount.x + k * unitCount.x * unitCount.y] + " ";
                }
            }
        }
        //Debug.Log("raw test sdfArr");
        //Debug.Log(tt);
        Save();
    }

    public void Save()
    {
        //struct MeshSDF
        //{
        //	startPos
        //	unitCount
        //	unit
        //	sdfArr
        //}

        var writer = FileHelper.BeginWrite(outPath);
        writer.Write(startUnitPos);
        writer.Write(unitCount);
        writer.Write(unit);
        writer.Write(sdfArr);
        writer.Close();

        Debug.Log("Mesh SDF Saved");
    }

    public void Parse(string path = "")
    {
        if (path == "")
        {
            path = outPath;
        }

        var reader = FileHelper.BeginRead(path);
        reader.Read(ref startUnitPos);
        reader.Read(ref unitCount);
        reader.Read(ref unit);
        reader.Read(ref sdfArr);
        reader.Close();

        UpdateDebugSDFColor();

        hasInited = true;
    }
}
