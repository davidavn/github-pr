
const bucketName = 'github-pr-metadata';
const s3ContentElement = document.getElementById('s3-content');
const s3FilesElement = document.getElementById('s3-files');


function fetchS3BucketContent() {
    fetch(`https://${bucketName}.s3.amazonaws.com/`)
        .then(response => response.text())
        .then(data => {
            const parser = new DOMParser();
            const xmlDoc = parser.parseFromString(data, 'text/xml');
            const contents = xmlDoc.getElementsByTagName('Contents');

            for (const content of contents) {
                const key = content.getElementsByTagName('Key')[0].textContent;
                const li = document.createElement('li');
                li.textContent = key;
                s3FilesElement.appendChild(li);
                fetch(`https://${bucketName}.s3.amazonaws.com/${key}`)
                    .then(response => {
                        if (!response.ok) {
                            throw new Error(`HTTP error! Status: ${response.status}`);
                        }
                        return response.text();
                    })
                    .then(content => {
                        console.log('Content:', content);
                        li.textContent = key + content;
                        s3FilesElement.appendChild(li);
                    })
                    .catch(error => {
                        console.error('Error fetching S3 object:', error);
                    });
            }
            s3ContentElement.style.display = 'block';
        })
        .catch(error => {
            console.error('Error fetching S3 bucket content:', error);
        });
}

// Call the function when the page is loaded
document.addEventListener('DOMContentLoaded', fetchS3BucketContent);
