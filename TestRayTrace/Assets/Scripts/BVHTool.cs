using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Debugger;

//start,end是tri，左闭右开
public struct BVHNode
{
    public int start;
    public int end;
    public Vector3 min;
    public Vector3 max;
}

struct Line
{
    public Vector3 p1;
    public Vector3 p2;
}

//参考：https://blog.csdn.net/weixin_39548859/article/details/107490251
//使用最简单的思路
//1.对于每个bbox，找3轴最长k轴切2分
//2.切2分的标准为，沿k轴，数量为一半的三角形 （根据三角形重心，按k轴排序）
//3.调整顺序后的tris传给BVHTrace(IBLTrace改)
public class BVHTool : MonoBehaviour
{
    static public float MAXFloat = 100000.0f;

    public int usrDepth = 1;   //用户建议的深度，当三角面数量够多，就会优先用这个浅的深度
    int depth = -1;             //深度从0开始

    public Material mat;

    Mesh mesh;
    Vector3[] vertices;
    public int[] tris;
    public BVHNode[] tree;
    public Color[] debugColors;

    List<Line> lines = new List<Line>();


    // Start is called before the first frame update
    void Start()
    {
        var meshFiliter = gameObject.GetComponent<MeshFilter>();
        mesh = meshFiliter.mesh;

        //Init();
    }

    // Update is called once per frame
    void Update()
    {
       
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
    }

    void OnRenderObject()
    {
        RenderBBox();
    }

    public void Init()
    {
        TimeLogger logger = new TimeLogger("BVHInit",false);
        logger.Start();
        vertices = mesh.vertices;
        ToWorldCoord();
        logger.LogSec();
        tris = mesh.triangles;

        Debug.Log(tris.Length/3+" tiangles");
        int triNum = tris.Length;
        int maxDepth = (int)Mathf.Log((float)triNum, 2.0f);
        depth = Mathf.Min(maxDepth, usrDepth);
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
        re.p1 = p1;
        re.p2 = p2;
        return re;
    }

    void AddRender(in BVHNode node)
    {
        // 4 5 6 7
        // 0 1 2 3
        var p = GetBBoxVerts(node.min, node.max);
        lines.Add(MakeLine(p[0], p[1]));
        lines.Add(MakeLine(p[1], p[2]));
        lines.Add(MakeLine(p[2], p[3]));
        lines.Add(MakeLine(p[3], p[0]));

        lines.Add(MakeLine(p[0], p[4]));
        lines.Add(MakeLine(p[1], p[5]));
        lines.Add(MakeLine(p[2], p[6]));
        lines.Add(MakeLine(p[3], p[7]));

        lines.Add(MakeLine(p[0+4], p[1+4]));
        lines.Add(MakeLine(p[1+4], p[2+4]));
        lines.Add(MakeLine(p[2+4], p[3+4]));
        lines.Add(MakeLine(p[3+4], p[0+4]));
    }

    void RenderBBox()
    {
        if (tree == null)
        {
            return;
        }
        for (int i = 0; i < tree.Length; i++)
        {
            mat.SetColor("_Color", debugColors[i]);
            mat.SetPass(0);
            GL.Color(new Color(1, 1, 0, 0.8f));
            GL.PushMatrix();
            GL.Begin(GL.LINES);

            for (int i1 = 0; i1 < 12; i1++)
            {
                GL.Vertex(lines[i1+i*12].p1);
                GL.Vertex(lines[i1+i*12].p2);
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
}
