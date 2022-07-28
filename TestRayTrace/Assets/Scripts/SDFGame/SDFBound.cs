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

public class SDFBound : MonoBehaviour
{
    public AnchorStrategy centerStrategy = AnchorStrategy.ByObject;
    [HideInInspector]
    public Vector3 center;
    public SizeStrategy boundStrategy = SizeStrategy.CustomSet;
    [HideInInspector]
    public Vector3 bound;
    public float judgeScale = 2;
    public Vector3 centerOffset = Vector3.zero;
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
            Gizmos.color = new Color(0, 0, 1);
            Gizmos.DrawWireCube(center, bound * 2);
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
}
