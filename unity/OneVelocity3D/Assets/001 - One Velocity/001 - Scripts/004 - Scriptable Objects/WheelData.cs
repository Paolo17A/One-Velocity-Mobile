using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "WheelData", menuName = "One Velocity/WheelData")]
public class WheelData : ScriptableObject
{
    [field: SerializeField] public string productID { get; set; }
    [field: SerializeField] public string productName { get; set; }
    [field: SerializeField] public Sprite wheelSprite { get; set; }
    [field: SerializeField] public float price { get; set; }
    [field: SerializeField][field: TextArea(minLines: 3, maxLines: 5)] public string description { get; set; }
}
