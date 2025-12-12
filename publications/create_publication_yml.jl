using Printf: @sprintf
using DocumenterCitations: CitationBibliography
using YAML: write_file

bib_file = "my_publications.bib"
bib = CitationBibliography(bib_file)
entries = bib.entries

dates = getproperty.(values(entries), :date)
idx_sort = sortperm(dates; rev=true)

create_authors(auths) = begin
    str = join([@sprintf("%s. %s",auth.first[1:1], auth.last) for auth in auths], ", ")
    return replace(str, "S. Schmitt" => "__S. Schmitt__")
end

yml = Dict{String,Any}[]
for k in collect(keys(entries))[idx_sort]
    entry_i = entries[k]
    category_i = String[]
    authors_i = create_authors(entry_i.authors)
    in_i = entry_i.in
    if entry_i.type == "article"
        citation_i = @sprintf("%s, *%s* %s (%s) %s.", authors_i, in_i.journal, in_i.volume, entry_i.date.year, in_i.pages)
        push!(category_i, "Journal Article")

    elseif entry_i.type == "inproceedings"
        citation_i = @sprintf("%s, In: *%s* (%s) %s.", authors_i, entry_i.booktitle, entry_i.date.year, in_i.pages)
        push!(category_i, "Conference Proceedings")

    elseif entry_i.type == "misc"
        citation_i = @sprintf("%s, *%s* (%s).", authors_i, in_i.publisher, entry_i.date.year)
        push!(category_i, "Preprint")

    elseif entry_i.type == "phdthesis"
        citation_i = "__S. Schmitt__, *PhD thesis*, RPTU University Kaiserslautern (2025)."
        push!(category_i, "PhD Thesis")

    else
        error("No citation method for type '$(entry_i.type)'")
    end
    
    yml_i = Dict{String,Any}(
        "title" => entry_i.title,
        "citation" => citation_i,
        "doi" => entry_i.access.doi,
        "categories" => category_i,
        "url" => entry_i.access.url,
        "image" => "publications/$(k).png",
    )
    push!(yml, yml_i)
end

write_file("my_publications.yml", yml)