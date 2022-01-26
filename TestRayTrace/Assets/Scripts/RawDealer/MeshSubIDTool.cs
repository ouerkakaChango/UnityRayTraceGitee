using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshSubIDTool : MonoBehaviour
{
    //int[] subIDs;
    public int[] cuts;
    Mesh mesh;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //×ó±ÕÓÒ¿ª
    void GetStartEndOf(int id, out int start, out int end)
    {
        if (id == 0)
        {
            start = 0;
            end = cuts[0];
        }
        else if (id == cuts.Length)
        {
            start = cuts[cuts.Length - 1];
            end = mesh.vertices.Length;
        }
        else
        {
            start = cuts[id - 1];
            end = cuts[id];
        }
    }

    public void Init()
    {
        var mf = GetComponent<MeshFilter>();
        mesh = mf.sharedMesh;

        int subMeshCount = mesh.subMeshCount;

        cuts = new int[subMeshCount - 1];

        for (int i = 0; i < subMeshCount; i++)
        {
            var desc = mesh.GetSubMesh(i);
            //Debug.Log("count " + desc.indexCount+"\n"+
            //    "start "+desc.indexStart+"\n"+
            //    "baseVert "+desc.baseVertex + "\n"+
            //    "vertCount "+desc.vertexCount+"\n"+
            //    "firstVert "+desc.firstVertex);
            if (i != 0)
            {
                cuts[i - 1] = desc.firstVertex;
            }
        }
    }

    public void ShowPointsOfID(int id)
    {
        int start, end;
        GetStartEndOf(id, out start, out end);
        Debug.Log("start " + start + " end " + end);

        var visual = GetComponent<PntsVisualizer>();
        visual.Clear();
        for (int i = start; i < end; i++)
        {
            visual.Add(mesh.vertices[i]+transform.position);
        }
    }


}
