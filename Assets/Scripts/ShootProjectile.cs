using UnityEngine;

public class ShootProjectile : MonoBehaviour
{
    public GameObject projectilePrefab;
    public float projectileSpeed = 1000f;
    public float shootingInterval = 0.1f; // Time between each shot
    public AudioClip playerShootSFX;
    public float shootingVolume = 0.5f; // Volume for the shooting sound

    private float lastShotTime;

    void Start()
    {
        lastShotTime = -shootingInterval; // Allows shooting immediately when the game starts
    }

    void Update()
    {
        if (Input.GetKey(KeyCode.Space) && Time.time - lastShotTime >= shootingInterval)
        {
            Shoot();
            lastShotTime = Time.time;
        }
    }

    void Shoot()
    {
        print("From shoot: " + projectilePrefab.tag);
        GameObject projectile = Instantiate(projectilePrefab, transform.position + transform.forward, transform.rotation) as GameObject;

        //Rigidbody rb = projectile.GetComponent<Rigidbody>();
        //rb.AddForce(transform.forward * projectileSpeed, ForceMode.VelocityChange);

        // projectile.transform.SetParent(GameObject.FindGameObjectWithTag("ProjectileParent").transform);

        AudioSource.PlayClipAtPoint(playerShootSFX, transform.position, shootingVolume);

        Destroy(projectile, 4f);
    }
}