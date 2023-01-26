defmodule Store.Repo.Migrations.DataMigrationAddConditions do
  use Ecto.Migration

  def change do
    execute("
      INSERT INTO conditions(id, name, inserted_at, updated_at) 
      SELECT 40, 'Sickle Cell Disease',  now(), now() UNION 
      SELECT 41, 'Osteogenesis Imperfecta',  now(), now() UNION 
      SELECT 42, 'Damage to the Nervous Tissue of the Spinal Cord with Objective Neurological Indication of Intractable Spasticity', now(), now() UNION 
      SELECT 43, 'Post Laminectomy Syndrome with Chronic Radiculopathy', now(), now() UNION 
      SELECT 44, 'Severe Psoriasis and Psoriatic Arthritis', now(), now() UNION 
      SELECT 45, 'Ulcerative Colitis', now(), now() UNION 
      SELECT 46, 'Cerebral Palsy', now(), now() UNION 
      SELECT 47, 'Cystic Fibrosis', now(), now() UNION 
      SELECT 48, 'Spasticity or Neuropathic Pain Associated with Fibromyalgia', now(), now() UNION 
      SELECT 49, 'Post Herpetic Neuralgia', now(), now() UNION 
      SELECT 50, 'Intractable Headache Syndromes', now(), now() UNION 
      SELECT 51, 'Neuropathic Facial Pain', now(), now() UNION 
      SELECT 52, 'Chronic Neuropathic Pain Associated with Degenerative Spinal Disorders', now(), now() UNION 
      SELECT 53, 'Terminal Illness', now(), now() UNION 
      SELECT 54, 'Decompensated Cirrhosis', now(), now() UNION 
      SELECT 55, 'Autism with Aggressive Behavior', now(), now() UNION 
      SELECT 56, 'Chronic Debilitating Migraine', now(), now() UNION 
      SELECT 57, 'Intractable Nausea', now(), now() UNION 
      SELECT 58, 'Anxiety Disorders', now(), now() UNION 
      SELECT 59, 'Autism', now(), now() UNION 
      SELECT 60, 'Cancer Remission Therapy', now(), now() UNION 
      SELECT 61, 'Neuropathies', now(), now() UNION 
      SELECT 62, 'Dyskinetic and Spastic Movement Disorders', now(), now() UNION 
      SELECT 63, 'Huntington''s Disease', now(), now() UNION 
      SELECT 64, 'Inflammatory Bowel Disease', now(), now() UNION 
      SELECT 65, 'Neurodegenerative Diseases', now(), now() UNION 
      SELECT 66, 'Opioid use Disorder', now(), now() UNION 
      SELECT 67, 'Severe Chronic or Intractable Pain', now(), now() UNION 
      SELECT 68, 'Sickle Cell Anemia', now(), now()
    ")
  end
end
