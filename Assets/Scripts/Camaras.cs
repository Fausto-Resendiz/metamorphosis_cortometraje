using System.IO;
using UnityEngine;

public class Camaras : MonoBehaviour
{
    public enum CamType
    {
        Barrido,
        Enfoque,
        Reloj
    }

    [SerializeField] GameObject[] cameras; // 0 barrido 1 enfoque 2 reloj
    [SerializeField] GameObject oruga, crisalida, mariposa;

    public Animator animatorO, animatorC;

    private void Awake()
    {
        foreach (GameObject cam in cameras)
            cam.SetActive(false);

        
        cameras[(int)CamType.Barrido].SetActive(true);

        try
        {
            animatorO = oruga.GetComponent<Animator>();
            animatorC = crisalida.GetComponent<Animator>();
        }
        catch { }
    }

    public void CambiarCamara(CamType tipo)
    {
        foreach (GameObject cam in cameras)
            cam.SetActive(false);

        cameras[(int)tipo].SetActive(true);
    }

    public void IrAOruga()
    {
        cameras[(int)CamType.Barrido].SetActive(false);
        animatorO.SetBool("caminar", true);

        CambiarCamara(CamType.Enfoque);
    }

    public void IrAReloj()
    {

        CambiarCamara(CamType.Reloj);
        cameras[(int)CamType.Barrido].SetActive(false);
        //oruga.SetActive(false);
        //crisalida.SetActive(true);
    }
    public void IrACrisalida()
    {
        animatorO.SetBool("caminar", false);
        CambiarCamara(CamType.Enfoque);
        cameras[(int)CamType.Barrido].SetActive(false);
        crisalida.SetActive(true);
        oruga.SetActive(false);
    }

    public void IrAMariposa()
    {
        CambiarCamara(CamType.Enfoque);
        cameras[(int)CamType.Barrido].SetActive(false);
        oruga.SetActive(false);
        //crisalida.SetActive(true);
        animatorC.enabled = false;
        mariposa.SetActive(true);
    }
}