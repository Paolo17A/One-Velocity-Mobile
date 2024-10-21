using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CarController : MonoBehaviour
{
    [SerializeField] private CarCore carCore;
    private void Awake()
    {
        carCore.onCarStateChange += CarStateChange;
        UnityGameManager.Instance.SceneController.ActionPass = true;
    }

    private void OnDisable()
    {
        carCore.onCarStateChange -= CarStateChange;
    }

    private void Start()
    {
        carCore.InitializeCarScene();
        carCore.CurrentCarState = CarCore.CarStates.CARS;
    }

    private void CarStateChange(object sender, EventArgs e)
    {
        switch (carCore.CurrentCarState)
        {
            case CarCore.CarStates.CARS:
                carCore.ShowCarSelectPanel();
                break;
            case CarCore.CarStates.OPTIONS:
                carCore.ShowOptionsPanel();
                break;
            case CarCore.CarStates.WHEELS:
                carCore.ShowWheelsPanel();
                break;
            case CarCore.CarStates.COLORS:
                carCore.ShowColorsPanel();
                break;
            case CarCore.CarStates.CONFIRM:
                carCore.ShowConfirmPanel();
                break;
            case CarCore.CarStates.DONE:
                carCore.ShowDonePanel();
                break;
        }
    }
}
