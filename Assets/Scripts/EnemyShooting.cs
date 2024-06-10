using UnityEngine;

public class EnemyShooting : MonoBehaviour
{
    public GameObject projectilePrefab;
    public float projectileSpeed = 1000f;
    public float minInterval = 1f; // Minimum interval between shots
    public float maxInterval = 3f; // Maximum interval between shots

    private float nextShootTime;

    void Start()
    {
        nextShootTime = Time.time + Random.Range(minInterval, maxInterval);
    }

    void Update()
    {
        if (Time.time >= nextShootTime)
        {
            Shoot();
            nextShootTime = Time.time + Random.Range(minInterval, maxInterval); // Set next shoot time
        }
    }

    void Shoot()
    {
        // Instantiate the projectile at the position slightly in front of the enemy
        GameObject projectile = Instantiate(projectilePrefab, transform.position + transform.forward, transform.rotation) as GameObject;

    }
}
