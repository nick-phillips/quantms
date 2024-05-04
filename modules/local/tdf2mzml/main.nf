
process TDF2MZML {
    tag "$meta.mzml_id"
    label 'process_single'
    label 'error_retry'

    container 'docker.io/mfreitas/tdf2mzml:latest' // I don't know which stable tag to use...

    input:
    tuple val(meta), path(rawfile)

    output:
    tuple val(meta), path("*.mzML"), emit: mzmls_converted
    path "versions.yml",   emit: version
    path "*.log",   emit: log

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.mzml_id}"

    """
    echo "Converting..." | tee --append ${rawfile.baseName}_conversion.log
    tdf2mzml.py -i *.d 2>&1 | tee --append ${rawfile.baseName}_conversion.log
    mv *.mzml ${file(rawfile.baseName).baseName}.mzML
    mv *.d ${file(rawfile.baseName).baseName}.d

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tdf2mzml.py: \$(tdf2mzml.py --version)
    END_VERSIONS
    """
}
