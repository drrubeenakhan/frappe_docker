# Custom ERPNext image with the restaurantops_erp app baked in, so a fresh
# deploy ships the integration contract (custom_external_ref fields + the
# least-privilege RestaurantOps Integration role and its permissions) as
# fixtures that auto-apply on `bench migrate` / `--install-app`.
#
# Build:
#   docker build -f restaurantops.Dockerfile -t restaurantops/erpnext:v16.25.0 .
#
# Use: point every frappe/erpnext service in pwd.yml at this image and add
#   --install-app restaurantops_erp to the create-site `bench new-site` command.
# See docs/runbooks/onprem-deployment.md (main repo) for the full procedure.
FROM frappe/erpnext:v16.25.0

USER frappe
COPY --chown=frappe:frappe ./custom_apps/restaurantops_erp \
     /home/frappe/frappe-bench/apps/restaurantops_erp

WORKDIR /home/frappe/frappe-bench
# Editable-install the app into the bench venv and register it in apps.txt.
# `sed '$a\'` guarantees a trailing newline first, so the base image's
# newline-less apps.txt doesn't concatenate ("erpnextrestaurantops_erp").
# (At runtime the `sites` volume shadows apps.txt; create-site/install-app keep
# the site's app list authoritative — see the runbook.)
RUN env/bin/pip install --no-cache-dir -e apps/restaurantops_erp \
 && if ! grep -qxF restaurantops_erp sites/apps.txt 2>/dev/null; then \
      sed -i -e '$a\' sites/apps.txt && echo restaurantops_erp >> sites/apps.txt; \
    fi
