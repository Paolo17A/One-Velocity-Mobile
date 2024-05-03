using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CarController : MonoBehaviour
{
    [SerializeField] private CarCore carCore;
    private void Awake()
    {
        UnityGameManager.Instance.SceneController.ActionPass = true;
    }

    private void Start()
    {
        carCore.InitializeCarScene();
    }
}
