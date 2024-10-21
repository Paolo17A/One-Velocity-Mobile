using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class CarSelectHandler : MonoBehaviour
{
    //=============================================================================================
    [SerializeField] private CarCore carCore;
    [SerializeField] private GameObject carModel;
    [SerializeField] private TextMeshProUGUI carNameTMP;
    //=============================================================================================

    public void DisplayThisCar()
    {
        carCore.SetSelectedCarName(carNameTMP.text);
        carCore.HideAllCarModels();
        carModel.SetActive(true);
    }
}
