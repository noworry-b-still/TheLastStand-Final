using UnityEngine;

public class EnemyBehavior : MonoBehaviour
{
    public Transform player; // Reference to the player's transform
    public float movementSpeed = 5f; // Speed at which the enemy moves towards the player
    float initialMoveSpeed;
    public float minDistance = 50f; // Minimum distance to maintain from the player
    float initialMinDistance;
    public int health = 100;

    public static int enemyCount = 0;

    void Awake()
    {
        player = GameObject.FindGameObjectWithTag("Player").transform;
    }
    void Start()
    {
        enemyCount++;
        initialMoveSpeed = movementSpeed;
        initialMinDistance = minDistance;
    }

    private void FixedUpdate()
    {
        // Check if the player's transform is assigned
        if (player != null)
        {
            // Calculate the direction towards the player
            Vector3 directionToPlayer = (player.position - transform.position).normalized;

            // Calculate the distance to the player
            float distanceToPlayer = Vector3.Distance(transform.position, player.position);

            // If the enemy is too close to the player, move away
            if (distanceToPlayer < minDistance)
            {
                directionToPlayer *= -1; // Move away from the player
                movementSpeed = initialMoveSpeed * 150;
                minDistance = initialMinDistance * 8;
                foreach (Transform child in gameObject.transform)
                {
                    if (child.name == "MachineGunHolder")
                    {
                        child.gameObject.SetActive(false);
                    }
                }
            }
            else
            {
                foreach (Transform child in gameObject.transform)
                {
                    if (child.name == "MachineGunHolder")
                    {
                        child.gameObject.SetActive(true);
                    }
                }
                movementSpeed = initialMoveSpeed;
                minDistance = initialMinDistance;
            }

            // Smoothly rotate towards the player's position
            Quaternion lookRotation = Quaternion.LookRotation(directionToPlayer);
            transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.fixedDeltaTime * 5f);

            // Move towards the player
            transform.position += transform.forward * movementSpeed * Time.fixedDeltaTime;
        }


    }

    // private void OnCollisionEnter(UnityEngine.Collision other)
    // {
    //     // Check if the enemy collides with an object tagged "PlayerBullet"
    //     //if (other.gameObject.CompareTag("PlayerBullet"))
    //     //{
    //     // Destroy(other.gameObject); // Destroy the bullet
    //     Debug.Log("Hit");
    //     Destroy(gameObject);

    //     //}
    // }

    // private void OnParticleCollision(GameObject other)
    // {
    //     Debug.Log("Enemy hit, this is not fully implemented");
    //     // NEED TO DETECT IF HIT BY PLAYER SO THEY ARE NOT IMMEDIATELY DESTROYED
    //     if (other.CompareTag("Player"))
    //     {
    //         // Reduce players HP by large margin to punish for collision
    //         Destroy(gameObject);
    //     }
    //     else
    //     {
    //         Destroy(other);
    //         Destroy(gameObject);
    //     }
    // }

    private void IncreasePlayerScore(int score)
    {
        PlayerHealth.playerScore += score;
        Debug.Log("Player score : " + PlayerHealth.playerScore);
        PlayerHealth playerHealth = FindObjectOfType<PlayerHealth>();
        if (playerHealth != null)
        {
            playerHealth.SetScoreText();
        }
    }

    private void OnDestroy()
    {
        enemyCount--;
        print("from destroy " + enemyCount);
        IncreasePlayerScore(1);

        if (enemyCount <= 0)
        {
            FindObjectOfType<LevelManager>().LevelBeat();
            PlayerHealth.playerScore = 0;
        }
    }


}
