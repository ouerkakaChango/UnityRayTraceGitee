using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.Vec;

public enum AnchorStrategy
{
    CustomSet,
    ByObject,
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
}
