// $ npm install website-scraper --save

const k8s = require('@kubernetes/client-node')

const mustache = require('mustache')

const request = require('request')

const JSONStream = require('json-stream')

const fs = require('fs').promises

const websiteScraper = require('website-scraper')

const timeouts = {}

const kc = new k8s.KubeConfig()

process.env.NODE_ENV === 'development' ? kc.loadFromDefault() : kc.loadFromCluster()

const opts = {}

kc.applyToRequest(opts)

const client = kc.makeApiClient(k8s.CoreV1Api)

const patch_client = kc.makeApiClient(k8s.CustomObjectsApi)

const path = '/usr/src/app/files'

const deleteFolder = async (folder) => {

  console.log('deleteFolder', folder)

  try {

    console.log('fs.stat', folder)

    await fs.stat(folder)

    console.log('fs.rmdir', folder)

    await fs.rmdir(folder, { recursive: false })

  } catch (error) {

    console.error('Error', error, folder)
  }
}

const splitUrl = (url) => {

  console.log('splitUrl', url)

  try {

    const { href, hostname } = new URL(url)

    console.log('href', href, 'hostname', hostname)

    return { href, hostname }

  } catch (error) {

    console.error('Error', error)

    return { href: null, hostname: null };
  }
}

const scratch = async (url, folder) => {

  console.log('scratch', url, folder)

  if (folder == 'undefined') {
    folder = ""
    return null
  }

  const options = {
    urls: [url],
    directory: path + '/' + folder
  }

  console.log('options', options)

  const { urls, directory } = options
  
  try {

    await deleteFolder(directory)

    const link = urls[0]

    console.log('link', link)

    const content = await websiteScraper(options)

    console.log('websiteScraper', link, directory, content)

    return { content, directory }

  } catch (error) {

    console.error('Error', directory, error)

    return { content: null, directory: null }
  }
}

function stringify(object) {

  console.log('stringify', object)

  var content = {}

  for (var prop in object) {

    if (!object.hasOwnProperty(prop)) {

      continue
    }

    if (typeof object[prop] == "object") {

      continue
    }

    if (typeof object[prop] == "function") {

      continue
    }

    content[prop] = object[prop]

  }

  var html_str = null

  if (content && content != 'undefined') {

    html_str = JSON.stringify(content)
  }

  console.log('stringify', html_str)

  return html_str
}

const sendRequestToApi = async (api, method = 'get', options = {}) => new Promise((resolve, reject) => request[method](`${kc.getCurrentCluster().server}${api}`, {...opts, ...options, headers: { ...options.headers, ...opts.headers }}, (err, res) => err ? reject(err) : resolve(JSON.parse(res.body))))

const fieldsFromDummySite = (object) => ({
  dummysite_name: object.metadata.name,
  container_name: object.metadata.name,
  //job_name: `${object.metadata.name}-job-${object.spec.length}`,
  job_name: `${object.metadata.name}-job-${object.spec.website_url}`,
  namespace: object.metadata.namespace,
  //delay: object.spec.delay,
  image: object.spec.image,
  //length: object.spec.length
  website_url: object.spec.website_url,
  html: object.spec.html
})

const fieldsFromJob = (object) => ({
  dummysite_name: object.metadata.labels.dummysite,
  container_name: object.metadata.labels.dummysite,
  //job_name: `${object.metadata.labels.dummysite}-job-${object.metadata.labels.length}`,
  job_name: `${object.metadata.labels.dummysite}-job-${object.metadata.labels.website_url}`,
  namespace: object.metadata.namespace,
  //delay: object.metadata.labels.delay,
  image: object.spec.template.spec.containers[0].image,
  //length: object.metadata.labels.length
  website_url: object.metadata.labels.website_url,
  html: object.metadata.labels.html
})

const getJobYAML = async (fields) => {

  const deploymentTemplate = await fs.readFile("job.mustache", "utf-8")

  return mustache.render(deploymentTemplate, fields)
}

const jobForDummySiteAlreadyExists = async (fields) => {

  const { dummysite_name, namespace } = fields

  const { items } = await sendRequestToApi(`/apis/batch/v1/namespaces/${namespace}/jobs`)

  return items.find(item => item.metadata.labels.dummysite === dummysite_name)
}

const createJob = async (fields) => {

  //console.log('Scheduling new job number', fields.length, 'for dummysite', fields.dummysite_name, 'to namespace', fields.namespace)

  console.log('Scheduling new job', fields.website_url, 'for dummysite', fields.dummysite_name, 'to namespace', fields.namespace)

  const yaml = await getJobYAML(fields)

  console.log('yaml', yaml)

  return sendRequestToApi(`/apis/batch/v1/namespaces/${fields.namespace}/jobs`, 'post', {
    headers: {
      'Content-Type': 'application/yaml'
    },
    body: yaml
  })
}

const removeJob = async ({ namespace, job_name }) => {

  const pods = await sendRequestToApi(`/api/v1/namespaces/${namespace}/pods/`)

  pods.items.filter(pod => pod.metadata.labels['job-name'] === job_name).forEach(pod => removePod({ namespace, pod_name: pod.metadata.name }))

  return sendRequestToApi(`/apis/batch/v1/namespaces/${namespace}/jobs/${job_name}`, 'delete')
}

const removeDummySite = ({ namespace, dummysite_name }) => sendRequestToApi(`/apis/dummysite.dwk/v1/namespaces/${namespace}/dummysites/${dummysite_name}`, 'delete')

const removePod = ({ namespace, pod_name }) => sendRequestToApi(`/api/v1/namespaces/${namespace}/pods/${pod_name}`, 'delete')

const cleanupForDummySite = async ({ namespace, dummysite_name }) => {

  console.log('Doing cleanup')

  clearTimeout(timeouts[dummysite_name])

  const jobs = await sendRequestToApi(`/apis/batch/v1/namespaces/${namespace}/jobs`)

  jobs.items.forEach(job => {

    if (!job.metadata.labels.dummysite === dummysite_name) return

    removeJob({ namespace, job_name: job.metadata.name })
  })
}

const rescheduleJob = (jobObject) => {

  const fields = fieldsFromJob(jobObject)

  console.log('rescheduleJob', fields)

  //if (Number(fields.length) <= 1) {
  //  console.log('DummySite ended. Removing dummysite.')
  //  return removeDummySite(fields)
  //}

  console.log('DummySite ended. Removing dummysite.')

  return removeDummySite(fields)

  // Save timeout so if the dummysite is suddenly removed we can prevent execution (removing dummysite removes job)
  /*timeouts[fields.dummysite_name] = setTimeout(() => {

    removeJob(fields)

    const newLength = Number(fields.length) - 1

    const newFields = {
      ...fields,
      job_name: `${fields.container_name}-job-${newLength}`,
      length: newLength
    }

    console.log('rescheduleJob', newFields)

    createJob(newFields)

  }, Number(fields.delay))*/
}

const maintainStatus = async () => {

  (await client.listPodForAllNamespaces()).body // A bug in the client(?) was fixed by sending a request and not caring about response

  /**
   * Watch DummySites
   */

  const dummysite_stream = new JSONStream()

  dummysite_stream.on('data', async ({ type, object }) => {

    const fields = fieldsFromDummySite(object)

    if (type === 'ADDED') {

      console.log('type', type)

      if (await jobForDummySiteAlreadyExists(fields)) return // Restarting application would create new 0th jobs without this check
      
      //createJob(fields)

      //object.spec.website_url

      const url = fields.website_url

      console.log('url', url)
      
      if (url && url != 'undefined') {

        const { href, hostname } = splitUrl(url)

        const { content, folder } = await scratch(href,hostname)

        if (content && content != 'undefined') {

          console.log('content', content, 'folder', folder)

          const content_object = content[0]

          const html_str = stringify(content_object)

          if (html_str && html_str != 'undefined') {

            const html_text = JSON.parse(html_str)?.text

            console.log('html_text', html_text)

            const { name, namespace } = object.metadata

            try {

              const newObject = {
                ...object,
                spec: {
                  ...object.spec,
                  html: html_text
                },
              }

              const patchOptions = {
                headers: {
                    "Content-type": "application/merge-patch+json",
                },
              }

              await patch_client.patchNamespacedCustomObject(
                "dummysite.dwk",
                "v1",
                namespace,
                "dummysites",
                name,
                newObject,
                undefined,
                undefined,
                undefined,
                patchOptions
              )

            } catch (error) {
              console.error('Error', error)
            }
          }
        }
      }
    }

    if (type === 'DELETED') cleanupForDummySite(fields)

  })

  request.get(`${kc.getCurrentCluster().server}/apis/dummysite.dwk/v1/dummysites?watch=true`, opts).pipe(dummysite_stream)

  /**
   * Watch Jobs
   */

  const job_stream = new JSONStream()

  job_stream.on('data', async ({ type, object }) => {

    if (!object.metadata.labels.dummysite) return // If it's not dummysite job don't handle
    if (type === 'DELETED' || object.metadata.deletionTimestamp) return // Do not handle deleted jobs
    if (!object?.status?.succeeded) return

    rescheduleJob(object)

    console.log('type', type, 'object', object)

  })

  request.get(`${kc.getCurrentCluster().server}/apis/batch/v1/jobs?watch=true`, opts).pipe(job_stream)

  console.log('job_stream', job_stream)

}

maintainStatus()