using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "PaintJobData", menuName = "One Velocity/PaintJobData")]
public class PaintJobData : ScriptableObject
{
    [field: SerializeField] public string serviceID { get; set; }
    [field: SerializeField] public string serviceName { get; set; }
    [field: SerializeField] public Color color { get; set; }
    [field: SerializeField] public float price { get; set; }
}
