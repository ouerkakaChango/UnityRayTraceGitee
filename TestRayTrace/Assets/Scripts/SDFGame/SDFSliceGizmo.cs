using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SDFSliceGizmo : MonoBehaviour
{
    public bool persistent = false;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
    }

    private void OnDrawGizmosSelected()
    {
        if (!persistent)
        {
            DrawSliceBox();
        }
    }

    private void OnDrawGizmos()
    {
        //Refresh();
        if(persistent)
        {
            DrawSliceBox();
        }
        CheckUpdateLayerAndMesh();
    }

    //################################################
    void DrawSliceBox()
    {
        var tag = gameObject.GetComponent<SDFBakerTag>();

        Gizmos.color = Color.blue;
        Matrix4x4 rotationMatrix = Matrix4x4.TRS(transform.position, transform.rotation, transform.lossyScale);
        Gizmos.matrix = rotationMatrix;
        Vector3 localScale = Vector3.one;
        localScale.y = 1.0f / transform.lossyScale.x * tag.hBound * 2;
        Gizmos.DrawWireCube(Vector3.zero, localScale);
        Gizmos.matrix = Matrix4x4.identity;
    }

    void CheckUpdateLayerAndMesh()
    {
        //1.check layer
        gameObject.layer = LayerMask.NameToLayer("SDFGizmo");
        //2.check mesh
        var mf = gameObject.GetComponent<MeshFilter>();
        if(mf == null)
        {
            mf = gameObject.AddComponent<MeshFilter>();
            //??? �Զ�����meshΪquad_1x1
        }
        var mr = gameObject.GetComponent<MeshRenderer>();
        if(mr == null)
        {
            mr = gameObject.AddComponent<MeshRenderer>();
        }
        var mat = mr.sharedMaterial;
        if(mat == null)
        {
            //Debug.Log("check mat");
            var shader = Resources.Load<Shader>("Shader/S_SDFSliceVisualize");
            mat = new Material(shader);
            var tag = gameObject.GetComponent<SDFBakerTag>();
            if(tag == null)
            {
                Debug.LogError("No sdf baker tag");
                return;
            }
            var texTag = tag.sliceTexTag;
            if(texTag == null)
            {
                Debug.LogError("No sliceTex of sdf baker tag");
                return;
            }
            mat.SetTexture("_MainTex", texTag.plainTextures[0].tex);
            if (texTag.useSubTex)
            {
                mat.SetVector("_SubInfo", new Vector4(texTag.edgeNum,texTag.edgeNum,texTag.subTexID,0));
            }
            else
            {
                mat.SetVector("_SubInfo", Vector4.zero);
            }
            mr.sharedMaterial = mat;
        }
    }

    public void Refresh()
    {
        var mr = gameObject.GetComponent<MeshRenderer>();
        mr.sharedMaterial = null;
    }
}
