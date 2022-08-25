using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.Vec;

public enum AnchorStrategy
{
    CustomSet,
    ByObject,
    LocalBase,//min角在obj的位置，朝向是local的x,y,z主宰
};

public enum SizeStrategy
{
    CustomSet,
    AutoIfPossible,
};

public enum SDFBoundType
{
    Default,
    SharedBound,
}

public class SDFBound : MonoBehaviour
{
    public SDFBoundType type = SDFBoundType.Default;

    public AnchorStrategy centerStrategy = AnchorStrategy.ByObject;
    [HideInInspector]
    public Vector3 center;
    public SizeStrategy boundStrategy = SizeStrategy.CustomSet;
    [HideInInspector]
    public Vector3 bound;
    public float judgeScale = 2;
    public Vector3 centerOffset = Vector3.zero;

    //---InnerBound
    [HideInInspector]
    public bool enableInnerBound = false;
    [HideInInspector]
    public float innerBoundRelativeScale = 0.9f;
    [HideInInspector]
    public float iDown = 1.0f;
    //___

    //---SharedBound
    [HideInInspector]
    public List<SDFBakerTag> sharedTags = new List<SDFBakerTag>();
    //___

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnDrawGizmos()
    {
        var tag = GetComponent<SDFBakerTag>();
        if(tag == null)
        {
            return;
        }
        if (isActiveAndEnabled && tag.isActiveAndEnabled)
        {
            if (type == SDFBoundType.Default)
            {
                Gizmos.color = new Color(0, 0, 1);
            }
            else if (type == SDFBoundType.SharedBound)
            {
                Gizmos.color = new Color(0, 1, 1);
            }
            Gizmos.DrawWireCube(center, bound * 2);

            if(enableInnerBound)
            {
                Vector3 bmin, bmax;
                GetInnerBoundMinMax(out bmin, out bmax);
                var icenter = (bmin + bmax) * 0.5f;
                Gizmos.color = new Color(1, 1, 0);
                Gizmos.DrawWireCube(icenter, (bmax-bmin));
            }
        }
    }

    //#####################################
    public Vector3 TryGetAutoBound()
    {
        Vector3 unitBound = new Vector3(0.5f, 0.5f, 0.5f);
        return Mul( unitBound, transform.lossyScale);
    }

    public Vector3 GetCenterByLocalBase()
    {
        var trans = gameObject.transform;
        var minPos = trans.position;
        var zDir = GetAlignedAxis(trans.forward);
        var xDir = GetAlignedAxis(trans.right);
        var yDir = GetAlignedAxis(trans.up);
        return minPos + bound.x * xDir + bound.y * yDir + bound.z * zDir;
    }

    public void GetInnerBoundMinMax(out Vector3 iboxmin, out Vector3 iboxmax)
    {
        iboxmin = center - Mul(bound , innerBoundRelativeScale * new Vector3(1,iDown,1));
        iboxmax = center + bound * innerBoundRelativeScale;
    }

    public int[] GetSharedObjIDs()
    {
        if(type!= SDFBoundType.SharedBound)
        {
            return null;
        }

        int[] re = new int[sharedTags.Count];
        for(int i=0;i<sharedTags.Count;i++)
        {
            re[i] = sharedTags[i].objInx;
        }
        return re;
    }
}
