using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PimbieSpawner : MonoBehaviour
{
    public GameObject enemyPrefab;
    public float xMin = -20;
    public float xMax = 20;
    public float yMin = 15;
    public float yMax = 20;
    public float zMin = -20;
    public float zMax = 20;
    public float spawnTime = 3;

    private int enemyCount = 0;
    private int maxEnemies;

    public enum Level
    {
        Level1,
        Level2,
        Level3
    }

    public Level currentLevel;

    void Start()
    {
        // Set the maximum number of enemies based on the current level
        switch (currentLevel)
        {
            case Level.Level1:
                maxEnemies = 3;
                break;
            case Level.Level2:
                maxEnemies = 5;
                break;
            case Level.Level3:
                maxEnemies = 7;
                break;
            default:
                maxEnemies = 1;
                break;
        }

        xMin = gameObject.transform.position.x + xMin;
        xMax = gameObject.transform.position.x + xMax;
        yMin = gameObject.transform.position.y + yMin;
        yMax = gameObject.transform.position.y + yMax;
        zMin = gameObject.transform.position.z + zMin;
        zMax = gameObject.transform.position.z + zMax;
        InvokeRepeating("SpawnEnemies", spawnTime, spawnTime);
    }

    void Update()
    {
    }

    void SpawnEnemies()
    {
        if (enemyCount >= maxEnemies)
        {
            CancelInvoke("SpawnEnemies");
            return;
        }

        Vector3 enemyPosition;
        enemyPosition.x = Random.Range(xMin, xMax);
        enemyPosition.y = Random.Range(yMin, yMax);
        enemyPosition.z = Random.Range(zMin, zMax);

        Instantiate(enemyPrefab, enemyPosition, transform.rotation);

        enemyCount++;  // Increment the counter each time an enemy is spawned
    }
}
