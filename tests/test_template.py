from pybeast import Template


def test_init():
    slurm_template = Template("examples/slurm.template")
    assert slurm_template.path == "examples/slurm.template"
