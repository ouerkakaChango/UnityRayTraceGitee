using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using XUtility;
using XFileHelper;
using FastGeo;
using Ray = FastGeo.Ray;
using static FastGeo.RayMath;
using AlgorithmHelper;
using Debugger;

//start,end是tri，左闭右开
public struct BVHNode
{
    public int start;
    public int end;
    public Vector3 min;
    public Vector3 max;
    
    public void Log()
    {
        Debug.Log("start:" + start + " end:" + end + " min:" + min + " max:" + max);
    }

    public static int GetBVHStride()
    {
        int vec3Size = sizeof(float) * 3;
        int intSize = sizeof(int);
        return vec3Size * 2 + intSize * 2;
    }
}


//参考：https://blog.csdn.net/weixin_39548859/article/details/107490251
//使用最简单的思路
//1.对于每个bbox，找3轴最长k轴切2分
//2.切2分的标准为，沿k轴，数量为一半的三角形 （根据三角形重心，按k轴排序）
//3.调整顺序后的tris传给BVHTrace(IBLTrace改)
[ExecuteInEditMode]
public class BVHTool : MonoBehaviour
{
    static public float MAXFloat = 100000.0f;

    public bool needVisualize = true;
    public bool importScale100 = false;
    public bool initOnStart = false;
    public int usrDepth = 1;   //用户建议的深度，当三角面数量够多，就会优先用这个浅的深度
    [ReadOnly]
    public int depth = -1;             //深度从0开始

    public Material debugLineMat;

    Mesh mesh;
    [HideInInspector]
    public Vector3[] vertices;
    [HideInInspector]
    public Vector3[] normals;
    [HideInInspector]
    public Vector2[] uvs;

    [HideInInspector]
    public int[] tris;
    public BVHNode[] tree;
    public Color[] debugColors;

    List<Line> lines = new List<Line>();

    public string savePath;
    public bool autoParseInEditorMode=false;

    //##########################################
    //## for CPU Trace BVH 
    //bool hasInitMeshWorldData = false;
    //Vector3[] world_vertices;
    //Vector3[] world_normals;
    //##########################################

    // Start is called before the first frame update
    void Start()
    {
        var meshFiliter = gameObject.GetComponent<MeshFilter>();
        mesh = meshFiliter.sharedMesh;
        if (debugLineMat == null)
        {
            Debug.Log("Set default line Mat");
            debugLineMat = Resources.Load("Material/DebugLine", typeof(Material)) as Material;
        }
        if (debugLineMat == null)
        {
            Debug.LogError("default mat not found");
        }
        if (initOnStart)
        {
            Init();
        }
        else
        {
            //if (autoParseInEditorMode)
            //{
            //    Parse();
            //}
        }
    }

    // Update is called once per frame
    void Update()
    {
       
    }

    void OnDrawGizmos()
    {

    }

    void OnRenderObject()
    {
        if (!needVisualize)
        {
            return;
        }
        RenderBBox();
    }

    public bool oldRender = false;
    public void Init()
    {
        TimeLogger logger = new TimeLogger("BVHInit",false);
        logger.Start();

        UpdateMeshInfos();
        if (oldRender)
        {
            ToWorldCoord();
        }
        logger.LogSec();
        tris = mesh.triangles;
        Debug.Log(mesh);
        Debug.Log(tris.Length/3+" tiangles");
        int triNum = tris.Length;
        int maxDepth = (int)Mathf.Log((float)triNum, 2.0f);
        depth = Mathf.Min(maxDepth, usrDepth);
        //treeLen = 2^(depth+1) - 1
        tree = new BVHNode[(int)(Mathf.Pow(2,depth+1))-1];
        debugColors = new Color[tree.Length];
        for(int i=0;i<debugColors.Length;i++)
        {
            debugColors[i] = new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f));
        }

        Debug.Log("BVH树深被设置为：" + depth);

        SetNode(0, tris.Length/3-1, 0);

        logger.LogSec();

        

        for (int i = 0; i < tree.Length;i++)
        {
            AddRender(tree[i]);
            //Debug.Log(tree[i].min+" "+ tree[i].max)
        }

        logger.LogSec();
    }

    void ToWorldCoord()
    {
        var local2world = gameObject.transform.localToWorldMatrix;
        for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i] = local2world.MultiplyPoint3x4(vertices[i]);
        }
    }

    void SetNode(int start, int end, int inx)
    {
        tree[inx].start = start;
        tree[inx].end = end;

        //1.算bbox
        //遍历，设置bbox的minmax X,Y,Z (2个float3)
        Vector3 min = Vector3.one * MAXFloat;
        Vector3 max = -Vector3.one * MAXFloat;

        for (int i = start; i <= end; i++)
        {
            var p1 = vertices[tris[3 * i]];
            var p2 = vertices[tris[3 * i + 1]];
            var p3 = vertices[tris[3 * i + 2]];

            CheckMinMax(p1, ref min, ref max);
            CheckMinMax(p2, ref min, ref max);
            CheckMinMax(p3, ref min, ref max);
        }
        tree[inx].min = min;
        tree[inx].max = max;

        //2.根据最长轴reArrange tris
        int leftTriNum = ReArrangeTrisByMaxAxis(min,max, start, end, inx);
        
        if (inx >= Mathf.Pow(2, depth)-1) 
        {//已经在最后一层
            return;
        }
        else
        {
            int lInx = 2 * inx + 1;
            int rInx = lInx + 1;
            //确定左右半范围，递归
            int lEnd = start + leftTriNum-1;
            //Debug.Log("切分：原[" + start + "," + end + "], " +
            //    "左:[" + start + "," + lEnd + "], " +
            //    "右:[" + (lEnd + 1) + "," + end + "]"
            //    );
            SetNode(start, lEnd, lInx);
            SetNode(lEnd+1, end, rInx);            
        }
    }

    int ReArrangeTrisByMaxAxis(in Vector3 min, in Vector3 max, int start, int end, int inx)
    {
        Vector3 size = max - min;
        int triNum = end - start+1;
        int type = -1;
        float mid = 0;
        if (size.x>=size.y && size.x>=size.z)
        {//按x切
            type = 0;
            mid = min.x + size.x / 2;
        }
        else if(size.y >= size.x && size.y >= size.z)
        {//按y切
            type = 1;
            mid = min.y + size.y / 2;
        }
        else
        {//按z切
            type = 2;
            mid = min.z + size.z / 2;
        }

        //1.新建排列数组newTri
        //2.遍历tri中原三角形，分左右放进newTri
        //3.将newTri覆盖回tri
        var newTri = new int[3*triNum];
        int l = 0, r = triNum -1;             //用于填放newTri的标记。左边的从左向右填，右边从右往左
        for (int i = start; i <= end; i++)
        {
            var p1 = vertices[tris[3 * i]];
            var p2 = vertices[tris[3 * i + 1]];
            var p3 = vertices[tris[3 * i + 2]];

            var triCen = (p1 + p2 + p3) / 3;
            bool bLeft = false;
            if(type==0 && triCen.x <= mid)
            {
                bLeft = true;
            }
            else if(type==1 && triCen.y <= mid)
            {
                bLeft = true;
            }
            else if(type==2 && triCen.z <= mid)
            {
                bLeft = true;
            }

            if (bLeft)
            {
                newTri[3 * l] = tris[3 * i];
                newTri[3 * l + 1] = tris[3 * i + 1];
                newTri[3 * l + 2] = tris[3 * i + 2];
                l += 1;
            }
            else
            {
                newTri[3 * r] = tris[3 * i];
                newTri[3 * r + 1] = tris[3 * i + 1];
                newTri[3 * r + 2] = tris[3 * i + 2];
                r -= 1;
            }          
        }

        //newTri覆盖回tris
        for (int i=start;i<=end;i++)
        {
            tris[3 * i + 0] = newTri[3 * (i-start) + 0];
            tris[3 * i + 1] = newTri[3 * (i-start) + 1];
            tris[3 * i + 2] = newTri[3 * (i-start) + 2];
        }
        return l;
    }

    void CheckMinMax(in Vector3 p, ref Vector3 min, ref Vector3 max)
    {
        if (p.x < min.x)
        {
            min.x = p.x;
        }
        if (p.y < min.y)
        {
            min.y = p.y;
        }
        if (p.z < min.z)
        {
            min.z = p.z;
        }

        if (p.x > max.x)
        {
            max.x = p.x;
        }
        if (p.y > max.y)
        {
            max.y = p.y;
        }
        if (p.z > max.z)
        {
            max.z = p.z;
        }
    }

    Line MakeLine(in Vector3 p1, in Vector3 p2)
    {
        Line re = new Line();
        re.a = p1;
        re.b = p2;
        return re;
    }

    void AddRender(in BVHNode node)
    {
        AddRender(node.min, node.max);
    }

    void AddRender(Vector3 min, Vector3 max)
    {
        // 4 5 6 7
        // 0 1 2 3
        var p = GetBBoxVerts(min, max);
        lines.Add(MakeLine(p[0], p[1]));
        lines.Add(MakeLine(p[1], p[2]));
        lines.Add(MakeLine(p[2], p[3]));
        lines.Add(MakeLine(p[3], p[0]));

        lines.Add(MakeLine(p[0], p[4]));
        lines.Add(MakeLine(p[1], p[5]));
        lines.Add(MakeLine(p[2], p[6]));
        lines.Add(MakeLine(p[3], p[7]));

        lines.Add(MakeLine(p[0 + 4], p[1 + 4]));
        lines.Add(MakeLine(p[1 + 4], p[2 + 4]));
        lines.Add(MakeLine(p[2 + 4], p[3 + 4]));
        lines.Add(MakeLine(p[3 + 4], p[0 + 4]));
    }

    void RenderBBox()
    {
        if (tree == null)
        {
            if (autoParseInEditorMode)
            {
                Parse();
            }
            return;
        }

        for (int i = 0; i < tree.Length; i++)
        {
            debugLineMat.SetColor("_Color", debugColors[i]);
            debugLineMat.SetPass(0);
            GL.Color(new Color(1, 1, 0, 0.8f));
            GL.PushMatrix();
            GL.Begin(GL.LINES);
            for (int i1 = 0; i1 < 12; i1++)
            {
                GL.Vertex(lines[i1+i*12].a+transform.position);
                GL.Vertex(lines[i1+i*12].b+transform.position);
            }

            GL.End();
            GL.PopMatrix();
        }
    }

    Vector3[] GetBBoxVerts(in Vector3 min, in Vector3 max)
    {
        Vector3[] re = new Vector3[8];
        re[0] = new Vector3(min.x, min.y, min.z);
        re[1] = new Vector3(max.x, min.y, min.z);
        re[2] = new Vector3(max.x, max.y, min.z);
        re[3] = new Vector3(min.x, max.y, min.z);
        re[4] = new Vector3(min.x, min.y, max.z);
        re[5] = new Vector3(max.x, min.y, max.z);
        re[6] = new Vector3(max.x, max.y, max.z);
        re[7] = new Vector3(min.x, max.y, max.z);
        return re;
    }

    void WriteNode(ref BinaryWriter writer, in BVHNode node)
    {
        writer.Write(node.start);
        writer.Write(node.end);
        writer.Write(node.min);
        writer.Write(node.max);
    }

    void ReadNode(ref BinaryReader reader, ref BVHNode node)
    {
        node.start = reader.ReadInt32();
        node.end = reader.ReadInt32();
        reader.Read(ref node.min);
        reader.Read(ref node.max);
    }

    public void Save()
    {
        //???
        Debug.Log("!!! tris not serilized");
        if (tree == null)
        {
            return;
        }
        var writer = FileHelper.BeginWrite(savePath);
        writer.Write(tris);
        writer.Write(tree.Length);
        for (int i = 0; i < tree.Length; i++)
        {
            WriteNode(ref writer, tree[i]);
        }
        writer.Close();
    }

    public void Parse(string path="")
    {
        //???
        Debug.Log("!!! tris not serilized");
        if (path == "")
        {
            path = savePath;
        }

        var reader = FileHelper.BeginRead(path);

        if (reader == null)
        {
            Debug.LogError("Error in parse:null");
            return;
        }

        reader.Read(ref tris);

        int treeLen = reader.ReadInt32();
        //treeLen = 2^(depth+1) - 1
        depth = (int)(Mathf.Log((float)(treeLen + 1), 2.0f)) - 1;
        usrDepth = depth;
        tree = new BVHNode[treeLen];
        lines.Clear();
        for (int i = 0; i < treeLen; i++)
        {
            ReadNode(ref reader, ref tree[i]);
            AddRender(tree[i]);
        }
        reader.Close();

        if (debugColors == null || debugColors.Length != tree.Length)
        {
            debugColors = new Color[tree.Length];
            for (int i = 0; i < debugColors.Length; i++)
            {
                debugColors[i] = new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f));
            }
        }
    }

    public bool IsInited()
    {
        return tree != null;
    }

    public HitInfo TraceWorldRay(Ray ray)
    {
        ray.pos -= transform.position;
        var re = TraceLocalRay(ray);
        re.P += transform.position;
        return re;
    }

        //!!! ray must be in local space
    const int MAXLEAVES = 32;
    //[To be Deprecated] CPU BVH Trace
    public HitInfo TraceLocalRay(Ray ray)
    {
        //Log.DebugRay(ray);
        HitInfo re = HitInfo.Default();

        TimeLogger logger = new TimeLogger("BVH.TraceLocalRay", false);
        logger.Start();
        //---
        int start = 0, end = tris.Length / 3 - 1;
        int[] toCheck = new int[MAXLEAVES]; //used as a stack
        int iter = 0; //used as a stack helper
        int nowInx = 0;
        while (true)
        {
            bool bLeafDetect = false;
            bool takeFromCheck = false;
            int nowDepth = AlgoHelper.GetTreeDepth(nowInx, depth);
            {//!!! Error situation
                if (nowDepth == -1 || nowDepth > depth)
                {
                    Debug.LogError("");
                    return re;
                }
            }
            BVHNode node = tree[nowInx];
            CastInfo castInfo = CastBBox(ray, node.min, node.max);

            if (!castInfo.bHit)
            {
                takeFromCheck = true;
            }
            else if (castInfo.bHit && nowDepth != depth)
            {
                int leftInx = 2 * nowInx + 1;
                int rightInx = 2 * nowInx + 2;
                CastInfo leftCast = CastBBox(ray, tree[leftInx].min, tree[leftInx].max);
                CastInfo rightCast = CastBBox(ray, tree[rightInx].min, tree[rightInx].max);
                if (leftCast.bHit && !rightCast.bHit)
                {
                    nowInx = leftInx;
                }
                else if (!leftCast.bHit && rightCast.bHit)
                {
                    nowInx = rightInx;
                }
                else if (leftCast.bHit && rightCast.bHit)
                {
                    if (leftCast.dis <= rightCast.dis)
                    {
                        nowInx = leftInx;
                        toCheck[iter] = rightInx;
                        iter++;
                    }
                    else
                    {
                        nowInx = rightInx;
                        toCheck[iter] = leftInx;
                        iter++;
                    }
                }
                else
                {
                    takeFromCheck = true;
                }
            }
            else if (castInfo.bHit && nowDepth == depth)
            {
                bLeafDetect = true;
                takeFromCheck = true;
            }

            if (bLeafDetect)
            {
                start = tree[nowInx].start;
                end = tree[nowInx].end;
                start = 3 * start;
                end = 3 * end + 3;

                //for loop all triangles in leave to trace
                for (int inx = start; inx < end; inx += 3)
                {
                    Vertex v1;
                    Vertex v2;
                    Vertex v3;

                    v1.p = vertices[tris[inx]];
                    v2.p = vertices[tris[inx + 1]];
                    v3.p = vertices[tris[inx + 2]];

                    v1.n = normals[tris[inx]];
                    v2.n = normals[tris[inx + 1]];
                    v3.n = normals[tris[inx + 2]];

                    HitInfo hit = RayCastTri(ray, v1, v2, v3);
                    if (hit.bHit)
                    {
                        if (!re.bHit)
                        {                           
                            re = hit;
                        }
                        else if ((hit.P - ray.pos).sqrMagnitude < (re.P - ray.pos).sqrMagnitude)
                        {
                            re = hit;
                        }
                    }
                }
                //___循环三角形
                if (re.bHit)
                {
                    break;
                }
            }//___if bLeafDetect
            if (takeFromCheck)
            {
                if (iter == 0)
                {
                    break;
                }
                else
                {
                    nowInx = toCheck[iter - 1];
                    iter--;
                }
            }
        }
        //___
        logger.Log();
        return re;
    }

    public void Test()
    {

    }

    public void UpdateMeshInfos()
    {
        var meshFiliter = gameObject.GetComponent<MeshFilter>();
        mesh = meshFiliter.sharedMesh;
        Debug.Log("update bvh mesh: " + mesh);
        vertices = mesh.vertices;
        normals = mesh.normals;
        uvs = mesh.uv;
        if (importScale100)
        {
            for (int i = 0; i < vertices.Length; i++)
            {
                vertices[i] *= 100.0f;
            }
            Debug.Log("import scale 100");
        }
    }
}
